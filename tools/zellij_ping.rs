use std::fs::{self, File};
use std::io::Write;
use std::process::{Command, Stdio};

const RED: &str = "#ff5555";
const GREEN: &str = "#50fa7b";
const YELLOW: &str = "#f1fa8c";
const WHITE: &str = "#f8f8f2";
const NO_NET: &str = "󰪎";
const BEST_NET: &str = "󰀳";
const OK_NET: &str = "󰖟";
const BAD_NET: &str = "󱂠";
const DEFAULT_PING_HOST: &str = "9.9.9.9";
const PING_LOG_FILE: &str = "/tmp/ping.log";
const PING_RESULT_FILE: &str = "/tmp/ping_result";
const PING_PID_FILE: &str = "/tmp/ping.pid";

fn is_number(value: &str) -> bool {
    value.chars().all(char::is_numeric)
}

fn min(a: i32, b: i32) -> i32 {
    if a < b { a } else { b }
}


fn ping_not_running() -> bool {
    if let Ok(pid) = fs::read_to_string(PING_PID_FILE) {
        if let Ok(output) = Command::new("ps")
            .arg("-p")
            .arg(pid.trim())
            .arg("-o")
            .arg("pid=")
            .output()
        {
            return String::from_utf8(output.stdout).unwrap().trim().is_empty();
        }
    }
    true
}


fn read_cached_result() -> i32 {
    fs::read_to_string(PING_RESULT_FILE)
        .ok()
        .and_then(|contents| contents.trim().parse::<i32>().ok())
        .unwrap_or(-1)
}

fn read_ping_result() -> i32 {
    fs::read_to_string(PING_LOG_FILE)
        .ok()
        .and_then(|contents| {
            contents
                .lines()
                .filter_map(|line| line.split('/').nth(4))
                .next()
                .and_then(|value| value.split('.').next())
                .and_then(|num| num.parse::<i32>().ok())
        })
        .unwrap_or(-1)
}

fn update_cached_result(value: i32) {
    if let Ok(mut file) = File::create(PING_RESULT_FILE) {
        let _ = writeln!(file, "{}", value);
    }
}

fn execute_ping(host: &str) {
    if let Ok(mut child) = Command::new("ping")
        .arg("-c")
        .arg("3")
        .arg("-t")
        .arg("255")
        .arg(host)
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .spawn()
    {
        if let  Ok(mut pid) = File::create(PING_PID_FILE) {
            let _ = writeln!(pid, "{}", child.id());
        }
    }
}

fn colorize_ping_value(ping: i32) -> &'static str {
    match ping {
        ping if ping < 1 || ping >= 1000 => RED,
        ping if ping < 100 => GREEN,
        ping if ping < 400 => WHITE,
        _ => YELLOW,
    }
}

fn ping_icon(ping: i32) -> &'static str {
    match ping {
        ping if ping < 1 || ping >= 1000 => NO_NET,
        ping if ping < 100 => BEST_NET,
        ping if ping < 400 => OK_NET,
        _ => BAD_NET,
    }
}

fn format_ping_value(value: i32) -> String {
    match value {
        -1 => "N/A".to_string(),
        value if value >= 1000 => format!(">{}K", min(value, 9999) / 1000),
        value => format!("{:3}", value),
    }
}

fn main() {
    let ping_host = std::env::var("ZELLIJ_PING_HOST").unwrap_or_else(|_| DEFAULT_PING_HOST.to_string());
    let ping_result;

    if ping_not_running() {
        ping_result = read_ping_result();
        update_cached_result(ping_result);
        execute_ping(&ping_host);
    } else {
        ping_result = read_cached_result();
    }

    let ping_value = ping_result;
    let formatted_ping = format_ping_value(ping_result);
    let output = format!(
        "#[fg={}] {} {}ms",
        colorize_ping_value(ping_value),
        ping_icon(ping_value),
        formatted_ping
    );

    print!("{}", output);
}
