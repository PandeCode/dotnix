#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#define MAX_PROCESSES 256
#define MAX_CMD_LEN 2048
#define MAX_PATH_LEN 512
#define HASH_SIZE 16
#define BASE_DIR "/tmp/procmgr"
#define DB_FILE BASE_DIR "/processes.db"

typedef struct {
  char hash[HASH_SIZE + 1];
  pid_t pid;
  char cmd[MAX_CMD_LEN];
  char pipe_path[MAX_PATH_LEN];
} Process;

// Fast non-cryptographic hash function (FNV-1a)
static uint64_t hash_fnv1a(const char *data, size_t len) {
  const uint64_t FNV_OFFSET_BASIS = 14695981039346656037ULL;
  const uint64_t FNV_PRIME = 1099511628211ULL;

  uint64_t hash = FNV_OFFSET_BASIS;
  for (size_t i = 0; i < len; i++) {
    hash ^= (uint8_t)data[i];
    hash *= FNV_PRIME;
  }
  return hash;
}

static void hash_command(const char *cmd, char *output) {
  uint64_t h1 = hash_fnv1a(cmd, strlen(cmd));
  uint64_t h2 = hash_fnv1a((char *)&h1,
                           sizeof(h1)); // Double hash for better distribution
  snprintf(output, HASH_SIZE + 1, "%016llx", (unsigned long long)(h1 ^ h2));
}

static void ensure_base_dir(void) {
  struct stat st;
  if (stat(BASE_DIR, &st) == -1) {
    mkdir(BASE_DIR, 0755);
  }
}

static int is_process_running(pid_t pid) { return kill(pid, 0) == 0; }

static int load_processes(Process *processes, int *count) {
  FILE *f = fopen(DB_FILE, "r");
  if (!f) {
    *count = 0;
    return 0;
  }

  *count = 0;
  char line[MAX_CMD_LEN + 100];
  while (fgets(line, sizeof(line), f) && *count < MAX_PROCESSES) {
    Process *p = &processes[*count];
    char *token = strtok(line, "\t");
    if (!token)
      continue;
    strncpy(p->hash, token, HASH_SIZE);
    p->hash[HASH_SIZE] = '\0';

    token = strtok(NULL, "\t");
    if (!token)
      continue;
    p->pid = atoi(token);

    token = strtok(NULL, "\t");
    if (!token)
      continue;
    strncpy(p->pipe_path, token, MAX_PATH_LEN - 1);
    p->pipe_path[MAX_PATH_LEN - 1] = '\0';

    token = strtok(NULL, "\n");
    if (!token)
      continue;
    strncpy(p->cmd, token, MAX_CMD_LEN - 1);
    p->cmd[MAX_CMD_LEN - 1] = '\0';

    // Remove dead processes
    if (!is_process_running(p->pid)) {
      unlink(p->pipe_path);
      continue;
    }

    (*count)++;
  }
  fclose(f);
  return 0;
}

static int save_processes(Process *processes, int count) {
  FILE *f = fopen(DB_FILE, "w");
  if (!f) {
    perror("Cannot save processes");
    return -1;
  }

  for (int i = 0; i < count; i++) {
    if (is_process_running(processes[i].pid)) {
      fprintf(f, "%s\t%d\t%s\t%s\n", processes[i].hash, processes[i].pid,
              processes[i].pipe_path, processes[i].cmd);
    } else {
      unlink(processes[i].pipe_path);
    }
  }
  fclose(f);
  return 0;
}

static Process *find_process_by_hash(Process *processes, int count,
                                     const char *hash) {
  for (int i = 0; i < count; i++) {
    if (strcmp(processes[i].hash, hash) == 0) {
      return &processes[i];
    }
  }
  return NULL;
}

static int start_process(const char *cmd, Process *p) {
  hash_command(cmd, p->hash);
  snprintf(p->pipe_path, MAX_PATH_LEN, "%s/%s.pipe", BASE_DIR, p->hash);
  strncpy(p->cmd, cmd, MAX_CMD_LEN - 1);
  p->cmd[MAX_CMD_LEN - 1] = '\0';

  // Create named pipe
  if (mkfifo(p->pipe_path, 0644) == -1 && errno != EEXIST) {
    perror("mkfifo");
    return -1;
  }

  pid_t pid = fork();
  if (pid == -1) {
    perror("fork");
    return -1;
  }

  if (pid == 0) {
    // Child process
    int fd = open(p->pipe_path, O_WRONLY);
    if (fd == -1) {
      perror("open pipe for writing");
      exit(1);
    }

    dup2(fd, STDOUT_FILENO);
    dup2(fd, STDERR_FILENO);
    close(fd);

    execl("/bin/sh", "sh", "-c", cmd, NULL);
    perror("execl");
    exit(1);
  }

  p->pid = pid;
  return 0;
}

static int read_from_pipe(const char *pipe_path) {
  int fd = open(pipe_path, O_RDONLY | O_NONBLOCK);
  if (fd == -1) {
    if (errno != ENOENT) {
      perror("open pipe for reading");
    }
    return -1;
  }

  char buffer[4096];
  char last_line[4096] = "";
  ssize_t bytes;

  // Read all available data and keep the last complete line
  while ((bytes = read(fd, buffer, sizeof(buffer) - 1)) > 0) {
    buffer[bytes] = '\0';
    char *line = strtok(buffer, "\n");
    while (line) {
      strncpy(last_line, line, sizeof(last_line) - 1);
      last_line[sizeof(last_line) - 1] = '\0';
      line = strtok(NULL, "\n");
    }
  }

  close(fd);

  if (strlen(last_line) > 0) {
    printf("%s\n", last_line);
    return 0;
  }
  return -1;
}

static void cleanup_dead_processes(Process *processes, int *count) {
  int write_idx = 0;
  for (int read_idx = 0; read_idx < *count; read_idx++) {
    if (is_process_running(processes[read_idx].pid)) {
      if (write_idx != read_idx) {
        processes[write_idx] = processes[read_idx];
      }
      write_idx++;
    } else {
      unlink(processes[read_idx].pipe_path);
    }
  }
  *count = write_idx;
}

int main(int argc, char *argv[]) {
  if (argc < 2) {
    fprintf(stderr, "Usage: %s [--kill|--killall|--list] <command...>\n",
            argv[0]);
    fprintf(stderr,
            "       %s <command...>  # Run or read from existing process\n",
            argv[0]);
    return 1;
  }

  ensure_base_dir();

  Process processes[MAX_PROCESSES];
  int process_count;
  load_processes(processes, &process_count);

  if (strcmp(argv[1], "--killall") == 0) {
    for (int i = 0; i < process_count; i++) {
      kill(processes[i].pid, SIGTERM);
      unlink(processes[i].pipe_path);
    }
    unlink(DB_FILE);
    printf("Killed all processes\n");
    return 0;
  }

  if (strcmp(argv[1], "--list") == 0) {
    cleanup_dead_processes(processes, &process_count);
    printf("Hash\t\tPID\tCommand\n");
    printf("----\t\t---\t-------\n");
    for (int i = 0; i < process_count; i++) {
      printf("%.8s\t%d\t%s\n", processes[i].hash, processes[i].pid,
             processes[i].cmd);
    }
    save_processes(processes, process_count);
    return 0;
  }

  // Build command string
  char cmd[MAX_CMD_LEN] = "";
  int cmd_start = 1;

  if (strcmp(argv[1], "--kill") == 0) {
    if (argc < 3) {
      fprintf(stderr, "Usage: %s --kill <command...>\n", argv[0]);
      return 1;
    }
    cmd_start = 2;
  }

  for (int i = cmd_start; i < argc; i++) {
    if (i > cmd_start)
      strcat(cmd, " ");
    strncat(cmd, argv[i], MAX_CMD_LEN - strlen(cmd) - 1);
  }

  if (strlen(cmd) == 0) {
    fprintf(stderr, "No command specified\n");
    return 1;
  }

  char hash[HASH_SIZE + 1];
  hash_command(cmd, hash);

  if (strcmp(argv[1], "--kill") == 0) {
    Process *p = find_process_by_hash(processes, process_count, hash);
    if (p && is_process_running(p->pid)) {
      kill(p->pid, SIGTERM);
      unlink(p->pipe_path);
      printf("Killed process %d (%s)\n", p->pid, cmd);
    } else {
      printf("Process not found or already dead\n");
    }
    cleanup_dead_processes(processes, &process_count);
    save_processes(processes, process_count);
    return 0;
  }

  // Normal execution - run or read
  Process *existing = find_process_by_hash(processes, process_count, hash);

  if (existing && is_process_running(existing->pid)) {
    // Process exists, read from pipe
    if (read_from_pipe(existing->pipe_path) == -1) {
      // If we can't read, the pipe might be empty, just exit silently
      return 1;
    }
  } else {
    // Process doesn't exist or is dead, start new one
    Process new_process;
    if (start_process(cmd, &new_process) == 0) {
      if (process_count < MAX_PROCESSES) {
        processes[process_count++] = new_process;
      }
      // Give the process a moment to start and produce output
      sleep(100000); // 100ms
      read_from_pipe(new_process.pipe_path);
    }
  }

  cleanup_dead_processes(processes, &process_count);
  save_processes(processes, process_count);
  return 0;
}
