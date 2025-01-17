#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <float.h>

float levenshtein(const char *s1, const char *s2);
float damerau_levenshtein(const char *s1, const char *s2);
float hamming(const char *s1, const char *s2);
float sift3(const char *s1, const char *s2);

float calculate_distance(const char *algorithm, const char *s1, const char *s2);

void print_usage(const char *program_name);

int main(int argc, char *argv[]) {
    if (argc < 3) {
        print_usage(argv[0]);
        return EXIT_FAILURE;
    }

    // Default values
    const char *algorithm = "levenshtein";
    const char *return_type = "str";
    const char *target = argv[1];
    char **candidates = NULL;
    int candidate_count = 0;

    // Parse arguments
    for (int i = 2; i < argc; i++) {
        if (strcmp(argv[i], "-a") == 0 || strcmp(argv[i], "--algorithm") == 0) {
            if (i + 1 < argc) {
                algorithm = argv[++i];
            } else {
                fprintf(stderr, "Error: Missing value for %s\n", argv[i]);
                return EXIT_FAILURE;
            }
        } else if (strcmp(argv[i], "-r") == 0 || strcmp(argv[i], "--return") == 0) {
            if (i + 1 < argc) {
                return_type = argv[++i];
            } else {
                fprintf(stderr, "Error: Missing value for %s\n", argv[i]);
                return EXIT_FAILURE;
            }
        } else {
            candidates = &argv[i];
            candidate_count = argc - i;
            break;
        }
    }

    if (candidate_count == 0) {
        fprintf(stderr, "Error: No candidates provided for comparison.\n");
        return EXIT_FAILURE;
    }

    const char *closest_candidate = NULL;
    float closest_distance = FLT_MAX;

    // Find the closest match
    for (int i = 0; i < candidate_count; i++) {
        float distance = calculate_distance(algorithm, target, candidates[i]);
        if (distance < closest_distance) {
            closest_distance = distance;
            closest_candidate = candidates[i];
        }
    }

    // Output based on return type
    if (strcmp(return_type, "str") == 0) {
        printf("%s\n", closest_candidate);
    } else if (strcmp(return_type, "dist") == 0) {
        printf("%.2f\n", closest_distance);
    } else if (strcmp(return_type, "both") == 0) {
        printf("%s %.2f\n", closest_candidate, closest_distance);
    } else {
        fprintf(stderr, "Error: Invalid return type '%s'\n", return_type);
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}

// Function to calculate distance based on the algorithm
float calculate_distance(const char *algorithm, const char *s1, const char *s2) {
    if (strcmp(algorithm, "levenshtein") == 0) {
        return levenshtein(s1, s2);
    } else if (strcmp(algorithm, "damerau") == 0) {
        return damerau_levenshtein(s1, s2);
    } else if (strcmp(algorithm, "hamming") == 0) {
        return hamming(s1, s2);
    } else if (strcmp(algorithm, "sift3") == 0) {
        return sift3(s1, s2);
    } else {
        fprintf(stderr, "Error: Invalid algorithm '%s'\n", algorithm);
        exit(EXIT_FAILURE);
    }
}

// Placeholder implementations for the algorithms
float levenshtein(const char *s1, const char *s2) {
    return (float)abs((int)strlen(s1) - (int)strlen(s2));
}

float damerau_levenshtein(const char *s1, const char *s2) {
    return (float)abs((int)strlen(s1) - (int)strlen(s2)) / 2.0f;
}

float hamming(const char *s1, const char *s2) {
    if (strlen(s1) != strlen(s2)) {
        fprintf(stderr, "Error: Strings must have the same length for Hamming distance.\n");
        exit(EXIT_FAILURE);
    }
    int distance = 0;
    for (size_t i = 0; i < strlen(s1); i++) {
        if (s1[i] != s2[i]) distance++;
    }
    return (float)distance;
}

float sift3(const char *s1, const char *s2) {
    return (float)(strlen(s1) > strlen(s2) ? strlen(s2) : strlen(s1)) / 2.0f;
}

// Print usage information
void print_usage(const char *program_name) {
    printf("Usage: %s <target> [-a <algorithm>] [-r <return_type>] <candidates>...\n", program_name);
    printf("\nOptions:\n");
    printf("  -a, --algorithm  Specify the algorithm (levenshtein, damerau, hamming, sift3). Default: levenshtein\n");
    printf("  -r, --return     Specify what to return (str, dist, both). Default: str\n");
    printf("\nExamples:\n");
    printf("  %s \"hannah\" -a levenshtein -r both \"hanna\" \"hannha\"\n", program_name);
}
