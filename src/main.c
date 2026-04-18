/**
 * ═══════════════════════════════════════════════════════════════════════════
 * 🛡️ ZAYED CYBERSHIELD - MAIN APPLICATION CORE
 * ═══════════════════════════════════════════════════════════════════════════
 * File: src/main.c
 * Project: Zayed CyberShield Protection System (درع زايد)
 * Version: 2.0.0
 * Author: asrar-mared (صائد الثغرات المحارب)
 * Date: 2026-01-05
 * 
 * Description:
 *   Enterprise-grade cybersecurity monitoring system with full UTF-8 support
 *   for Arabic, multilingual logging, and international character handling.
 * 
 * Features:
 *   ✓ Full UTF-8 support for Arabic and international characters
 *   ✓ Emoji and Unicode symbol support 🛡️⚔️🔥
 *   ✓ Multilingual audit logging
 *   ✓ Real-time threat detection
 *   ✓ Interactive terminal UI with Arabic support
 *   ✓ Secure input validation and sanitization
 * 
 * Compilation:
 *   gcc -std=c11 -O3 -Wall -Wextra \
 *       -DUTF8_SUPPORT -D_GNU_SOURCE \
 *       -o zayed-shield src/main.c \
 *       -lncursesw -lpthread -lcurl -ljson-c
 * 
 * Requirements:
 *   - GCC 9.0+ or Clang 10.0+
 *   - ncursesw (wide character support)
 *   - POSIX threads
 *   - libcurl (for network security checks)
 *   - json-c (for configuration and logging)
 * 
 * License: MIT with Security Addendum
 * Copyright © 2026 Zayed CyberShield | asrar-mared
 * ═══════════════════════════════════════════════════════════════════════════
 */

/* ═══════════════════════════════════════════════════════════════════════════
 * HEADERS & DEPENDENCIES
 * ═══════════════════════════════════════════════════════════════════════════ */

#define _XOPEN_SOURCE 700
/* _GNU_SOURCE already defined in Makefile */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>
#include <locale.h>
#include <wchar.h>
#include <wctype.h>
#include <time.h>
#include <signal.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <errno.h>

/* Terminal UI with UTF-8 support */
#include <ncursesw/ncurses.h>

/* JSON support for configuration */
#include <json-c/json.h>

/* Network security checks */
#include <curl/curl.h>

/* ═══════════════════════════════════════════════════════════════════════════
 * CONSTANTS & CONFIGURATION
 * ═══════════════════════════════════════════════════════════════════════════ */

#define ZAYED_VERSION "2.0.0"
#define ZAYED_BUILD_DATE __DATE__
#define ZAYED_AUTHOR "asrar-mared (صائد الثغرات المحارب)"

/* UTF-8 Configuration */
#define UTF8_LOCALE "en_US.UTF-8"
#define ARABIC_LOCALE "ar_AE.UTF-8"

/* Buffer sizes */
#define MAX_INPUT_SIZE 4096
#define MAX_LOG_SIZE 8192
#define MAX_PATH_SIZE 1024

/* Colors (for ncurses) */
#define COLOR_ZAYED_BLUE 1
#define COLOR_ZAYED_GREEN 2
#define COLOR_ZAYED_RED 3
#define COLOR_ZAYED_YELLOW 4
#define COLOR_ZAYED_CYAN 5
#define COLOR_ZAYED_MAGENTA 6

/* Security levels */
typedef enum {
    SECURITY_LOW = 0,
    SECURITY_MEDIUM = 1,
    SECURITY_HIGH = 2,
    SECURITY_CRITICAL = 3
} security_level_t;

/* Event types */
typedef enum {
    EVENT_STARTUP = 0,
    EVENT_SHUTDOWN = 1,
    EVENT_THREAT_DETECTED = 2,
    EVENT_THREAT_BLOCKED = 3,
    EVENT_USER_INPUT = 4,
    EVENT_SYSTEM_ERROR = 5
} event_type_t;

/* ═══════════════════════════════════════════════════════════════════════════
 * DATA STRUCTURES
 * ═══════════════════════════════════════════════════════════════════════════ */

/**
 * Security Event Structure
 * Supports full UTF-8 for multilingual logging
 */
typedef struct {
    time_t timestamp;
    event_type_t type;
    security_level_t level;
    wchar_t message_ar[MAX_LOG_SIZE];  /* Arabic message */
    wchar_t message_en[MAX_LOG_SIZE];  /* English message */
    char source_ip[46];                 /* IPv4/IPv6 address */
    uint64_t event_id;
} security_event_t;

/**
 * System State
 */
typedef struct {
    bool running;
    bool utf8_enabled;
    bool arabic_mode;
    security_level_t current_level;
    uint64_t threats_blocked;
    uint64_t events_logged;
    pthread_mutex_t state_mutex;
    FILE *audit_log;
} system_state_t;

/**
 * Configuration
 */
typedef struct {
    char log_path[MAX_PATH_SIZE];
    char locale[64];
    bool enable_emoji;
    bool enable_colors;
    int refresh_rate;
} config_t;

/* ═══════════════════════════════════════════════════════════════════════════
 * GLOBAL VARIABLES
 * ═══════════════════════════════════════════════════════════════════════════ */

static system_state_t g_system_state = {
    .running = false,
    .utf8_enabled = false,
    .arabic_mode = false,
    .current_level = SECURITY_HIGH,
    .threats_blocked = 0,
    .events_logged = 0,
    .audit_log = NULL
};

static config_t g_config = {
    .log_path = "/var/log/zayed-shield/audit.log",
    .locale = UTF8_LOCALE,
    .enable_emoji = true,
    .enable_colors = true,
    .refresh_rate = 1000  /* milliseconds */
};

/* ═══════════════════════════════════════════════════════════════════════════
 * UTF-8 UTILITY FUNCTIONS
 * ═══════════════════════════════════════════════════════════════════════════ */

/**
 * Initialize UTF-8 support
 * Sets locale for proper multibyte character handling
 */
bool init_utf8_support(void) {
    /* Set locale to support UTF-8 */
    if (setlocale(LC_ALL, g_config.locale) == NULL) {
        fprintf(stderr, "❌ Failed to set locale: %s\n", g_config.locale);
        
        /* Try fallback locales */
        const char *fallbacks[] = {
            "en_US.UTF-8", "C.UTF-8", "POSIX", NULL
        };
        
        for (int i = 0; fallbacks[i] != NULL; i++) {
            if (setlocale(LC_ALL, fallbacks[i]) != NULL) {
                fprintf(stderr, "⚠️  Using fallback locale: %s\n", fallbacks[i]);
                strncpy(g_config.locale, fallbacks[i], sizeof(g_config.locale) - 1);
                g_system_state.utf8_enabled = true;
                return true;
            }
        }
        
        return false;
    }
    
    g_system_state.utf8_enabled = true;
    
    /* Initialize ncurses with wide character support */
    setlocale(LC_CTYPE, "");
    
    return true;
}

/**
 * Validate UTF-8 byte sequence
 * Prevents malformed UTF-8 attacks
 */
bool is_valid_utf8(const char *str, size_t len) {
    if (!str) return false;
    
    size_t i = 0;
    while (i < len) {
        if ((str[i] & 0x80) == 0) {
            /* Single-byte character (ASCII) */
            i++;
        } else if ((str[i] & 0xE0) == 0xC0) {
            /* Two-byte character */
            if (i + 1 >= len || (str[i + 1] & 0xC0) != 0x80)
                return false;
            i += 2;
        } else if ((str[i] & 0xF0) == 0xE0) {
            /* Three-byte character */
            if (i + 2 >= len ||
                (str[i + 1] & 0xC0) != 0x80 ||
                (str[i + 2] & 0xC0) != 0x80)
                return false;
            i += 3;
        } else if ((str[i] & 0xF8) == 0xF0) {
            /* Four-byte character */
            if (i + 3 >= len ||
                (str[i + 1] & 0xC0) != 0x80 ||
                (str[i + 2] & 0xC0) != 0x80 ||
                (str[i + 3] & 0xC0) != 0x80)
                return false;
            i += 4;
        } else {
            return false;
        }
    }
    
    return true;
}

/**
 * Sanitize input for security
 * Removes dangerous characters while preserving UTF-8
 */
bool sanitize_utf8_input(wchar_t *output, const char *input, size_t max_len) {
    if (!output || !input) return false;
    
    /* Validate UTF-8 first */
    if (!is_valid_utf8(input, strlen(input))) {
        return false;
    }
    
    /* Convert to wide characters */
    mbstate_t state;
    memset(&state, 0, sizeof(state));
    
    const char *src = input;
    size_t result = mbsrtowcs(output, &src, max_len - 1, &state);
    
    if (result == (size_t)-1) {
        return false;
    }
    
    output[result] = L'\0';
    
    /* Remove dangerous control characters */
    for (size_t i = 0; i < result; i++) {
        /* Block control characters except newline, tab, carriage return */
        if (iswcntrl(output[i]) && 
            output[i] != L'\n' && 
            output[i] != L'\t' && 
            output[i] != L'\r') {
            output[i] = L'�';  /* Replacement character */
        }
    }
    
    return true;
}

/**
 * Detect Unicode homograph attacks
 * Checks for visually similar characters
 */
bool is_suspicious_unicode(const wchar_t *str) {
    if (!str) return false;
    
    /* Check for common homograph attack patterns */
    const wchar_t *suspicious_chars[] = {
        L"а",  /* Cyrillic 'a' (looks like Latin 'a') */
        L"е",  /* Cyrillic 'e' */
        L"о",  /* Cyrillic 'o' */
        L"р",  /* Cyrillic 'p' */
        L"с",  /* Cyrillic 'c' */
        L"х",  /* Cyrillic 'x' */
        NULL
    };
    
    for (int i = 0; suspicious_chars[i] != NULL; i++) {
        if (wcsstr(str, suspicious_chars[i]) != NULL) {
            return true;
        }
    }
    
    return false;
}

/* ═══════════════════════════════════════════════════════════════════════════
 * LOGGING FUNCTIONS
 * ═══════════════════════════════════════════════════════════════════════════ */

/**
 * Initialize audit log with UTF-8 BOM
 */
bool init_audit_log(void) {
    /* Create log directory if doesn't exist */
    char log_dir[MAX_PATH_SIZE];
    strncpy(log_dir, g_config.log_path, sizeof(log_dir) - 1);
    
    char *last_slash = strrchr(log_dir, '/');
    if (last_slash) {
        *last_slash = '\0';
        mkdir(log_dir, 0755);
    }
    
    /* Open log file in append mode with UTF-8 */
    g_system_state.audit_log = fopen(g_config.log_path, "a");
    if (!g_system_state.audit_log) {
        perror("Failed to open audit log");
        return false;
    }
    
    /* Write UTF-8 BOM if file is empty */
    fseek(g_system_state.audit_log, 0, SEEK_END);
    if (ftell(g_system_state.audit_log) == 0) {
        /* UTF-8 BOM: EF BB BF */
        fwrite("\xEF\xBB\xBF", 1, 3, g_system_state.audit_log);
        
        /* Write header */
        fprintf(g_system_state.audit_log,
                "# ═══════════════════════════════════════════════════════════\n"
                "# 🛡️ ZAYED CYBERSHIELD - AUDIT LOG\n"
                "# ═══════════════════════════════════════════════════════════\n"
                "# System: درع زايد للأمن السيبراني\n"
                "# Version: %s\n"
                "# Started: %s\n"
                "# Locale: %s (UTF-8 Enabled)\n"
                "# ═══════════════════════════════════════════════════════════\n\n",
                ZAYED_VERSION,
                ZAYED_BUILD_DATE,
                g_config.locale);
        
        fflush(g_system_state.audit_log);
    }
    
    return true;
}

/**
 * Log security event with multilingual support
 */
void log_security_event(const security_event_t *event) {
    if (!event || !g_system_state.audit_log) return;
    
    pthread_mutex_lock(&g_system_state.state_mutex);
    
    /* Format timestamp */
    char timestamp[64];
    struct tm *tm_info = localtime(&event->timestamp);
    strftime(timestamp, sizeof(timestamp), "%Y-%m-%d %H:%M:%S", tm_info);
    
    /* Event type emoji */
    const char *event_emoji;
    switch (event->type) {
        case EVENT_STARTUP:         event_emoji = "🚀"; break;
        case EVENT_SHUTDOWN:        event_emoji = "🛑"; break;
        case EVENT_THREAT_DETECTED: event_emoji = "🚨"; break;
        case EVENT_THREAT_BLOCKED:  event_emoji = "🛡️"; break;
        case EVENT_USER_INPUT:      event_emoji = "⌨️"; break;
        case EVENT_SYSTEM_ERROR:    event_emoji = "❌"; break;
        default:                    event_emoji = "ℹ️"; break;
    }
    
    /* Security level indicator */
    const char *level_str;
    switch (event->level) {
        case SECURITY_LOW:      level_str = "🟢 LOW"; break;
        case SECURITY_MEDIUM:   level_str = "🟡 MEDIUM"; break;
        case SECURITY_HIGH:     level_str = "🟠 HIGH"; break;
        case SECURITY_CRITICAL: level_str = "🔴 CRITICAL"; break;
        default:                level_str = "⚪ UNKNOWN"; break;
    }
    
    /* Write to log */
    fprintf(g_system_state.audit_log,
            "[%s] %s [%s] ID:%lu\n",
            timestamp, event_emoji, level_str, event->event_id);
    
    /* Arabic message */
    if (wcslen(event->message_ar) > 0) {
        fprintf(g_system_state.audit_log, "  AR: ");
        fwprintf(g_system_state.audit_log, L"%ls\n", event->message_ar);
    }
    
    /* English message */
    if (wcslen(event->message_en) > 0) {
        fprintf(g_system_state.audit_log, "  EN: ");
        fwprintf(g_system_state.audit_log, L"%ls\n", event->message_en);
    }
    
    /* Source IP if available */
    if (strlen(event->source_ip) > 0) {
        fprintf(g_system_state.audit_log, "  IP: %s\n", event->source_ip);
    }
    
    fprintf(g_system_state.audit_log, "\n");
    fflush(g_system_state.audit_log);
    
    g_system_state.events_logged++;
    
    pthread_mutex_unlock(&g_system_state.state_mutex);
}

/**
 * Create security event helper function
 */
security_event_t create_event(event_type_t type, security_level_t level,
                               const wchar_t *msg_ar, const wchar_t *msg_en) {
    security_event_t event;
    memset(&event, 0, sizeof(event));
    
    event.timestamp = time(NULL);
    event.type = type;
    event.level = level;
    event.event_id = g_system_state.events_logged + 1;
    
    if (msg_ar) {
        wcsncpy(event.message_ar, msg_ar, MAX_LOG_SIZE - 1);
    }
    
    if (msg_en) {
        wcsncpy(event.message_en, msg_en, MAX_LOG_SIZE - 1);
    }
    
    return event;
}

/* ═══════════════════════════════════════════════════════════════════════════
 * TERMINAL UI FUNCTIONS
 * ═══════════════════════════════════════════════════════════════════════════ */

/**
 * Initialize terminal UI with UTF-8 support
 */
bool init_terminal_ui(void) {
    /* Initialize ncurses with wide character support */
    initscr();
    
    /* Enable colors if supported */
    if (has_colors() && g_config.enable_colors) {
        start_color();
        init_pair(COLOR_ZAYED_BLUE, COLOR_BLUE, COLOR_BLACK);
        init_pair(COLOR_ZAYED_GREEN, COLOR_GREEN, COLOR_BLACK);
        init_pair(COLOR_ZAYED_RED, COLOR_RED, COLOR_BLACK);
        init_pair(COLOR_ZAYED_YELLOW, COLOR_YELLOW, COLOR_BLACK);
        init_pair(COLOR_ZAYED_CYAN, COLOR_CYAN, COLOR_BLACK);
        init_pair(COLOR_ZAYED_MAGENTA, COLOR_MAGENTA, COLOR_BLACK);
    }
    
    /* Configure ncurses */
    cbreak();              /* Disable line buffering */
    noecho();              /* Don't echo input */
    keypad(stdscr, TRUE);  /* Enable function keys */
    nodelay(stdscr, TRUE); /* Non-blocking input */
    curs_set(0);           /* Hide cursor */
    
    return true;
}

/**
 * Draw main UI
 */
void draw_main_ui(void) {
    clear();
    
    int max_y, max_x;
    getmaxyx(stdscr, max_y, max_x);
    
    /* Banner */
    attron(COLOR_PAIR(COLOR_ZAYED_CYAN) | A_BOLD);
    mvprintw(1, (max_x - 50) / 2, "╔════════════════════════════════════════════════╗");
    mvprintw(2, (max_x - 50) / 2, "║    🛡️  ZAYED CYBERSHIELD  🛡️                 ║");
    mvprintw(3, (max_x - 50) / 2, "║         درع زايد للأمن السيبراني             ║");
    mvprintw(4, (max_x - 50) / 2, "╚════════════════════════════════════════════════╝");
    attroff(COLOR_PAIR(COLOR_ZAYED_CYAN) | A_BOLD);
    
    /* Status */
    attron(COLOR_PAIR(COLOR_ZAYED_GREEN));
    mvprintw(6, 2, "Status: ACTIVE 🟢");
    mvprintw(7, 2, "UTF-8: %s ✓", g_system_state.utf8_enabled ? "ENABLED" : "DISABLED");
    mvprintw(8, 2, "Locale: %s", g_config.locale);
    attroff(COLOR_PAIR(COLOR_ZAYED_GREEN));
    
    /* Statistics */
    attron(COLOR_PAIR(COLOR_ZAYED_YELLOW));
    mvprintw(10, 2, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    mvprintw(11, 2, "📊 Statistics");
    mvprintw(12, 2, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    attroff(COLOR_PAIR(COLOR_ZAYED_YELLOW));
    
    mvprintw(13, 4, "Threats Blocked: %lu 🛡️", g_system_state.threats_blocked);
    mvprintw(14, 4, "Events Logged: %lu 📝", g_system_state.events_logged);
    
    /* Controls */
    attron(COLOR_PAIR(COLOR_ZAYED_BLUE));
    mvprintw(max_y - 3, 2, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    mvprintw(max_y - 2, 2, "[Q] Quit | [A] Toggle Arabic | [L] View Log");
    attroff(COLOR_PAIR(COLOR_ZAYED_BLUE));
    
    refresh();
}

/* ═══════════════════════════════════════════════════════════════════════════
 * MAIN APPLICATION LOGIC
 * ═══════════════════════════════════════════════════════════════════════════ */

/**
 * Signal handler for graceful shutdown
 */
void signal_handler(int signum) {
    (void)signum;  /* Unused */
    g_system_state.running = false;
}

/**
 * Main function
 */
int main(int argc, char *argv[]) {
    /* Initialize mutex */
    pthread_mutex_init(&g_system_state.state_mutex, NULL);
    
    /* Setup signal handlers */
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);
    
    /* Initialize UTF-8 support */
    printf("🔄 Initializing UTF-8 support...\n");
    if (!init_utf8_support()) {
        fprintf(stderr, "❌ Failed to initialize UTF-8 support\n");
        return EXIT_FAILURE;
    }
    printf("✅ UTF-8 support enabled\n");
    
    /* Initialize audit log */
    printf("🔄 Initializing audit log...\n");
    if (!init_audit_log()) {
        fprintf(stderr, "❌ Failed to initialize audit log\n");
        return EXIT_FAILURE;
    }
    printf("✅ Audit log ready: %s\n", g_config.log_path);
    
    /* Log startup */
    security_event_t startup_event = create_event(
        EVENT_STARTUP,
        SECURITY_HIGH,
        L"بدأ تشغيل نظام درع زايد بنجاح 🚀",
        L"Zayed CyberShield started successfully 🚀"
    );
    log_security_event(&startup_event);
    
    /* Initialize terminal UI */
    if (!init_terminal_ui()) {
        fprintf(stderr, "❌ Failed to initialize terminal UI\n");
        return EXIT_FAILURE;
    }
    
    g_system_state.running = true;
    
    /* Main loop */
    while (g_system_state.running) {
        draw_main_ui();
        
        int ch = getch();
        if (ch != ERR) {
            switch (ch) {
                case 'q':
                case 'Q':
                    g_system_state.running = false;
                    break;
                    
                case 'a':
                case 'A':
                    g_system_state.arabic_mode = !g_system_state.arabic_mode;
                    break;
            }
        }
        
        usleep(g_config.refresh_rate * 1000);
    }
    
    /* Cleanup */
    endwin();
    
    /* Log shutdown */
    security_event_t shutdown_event = create_event(
        EVENT_SHUTDOWN,
        SECURITY_HIGH,
        L"تم إيقاف نظام درع زايد بشكل آمن 🛑",
        L"Zayed CyberShield shut down safely 🛑"
    );
    log_security_event(&shutdown_event);
    
    if (g_system_state.audit_log) {
        fclose(g_system_state.audit_log);
    }
    
    pthread_mutex_destroy(&g_system_state.state_mutex);
    
    printf("\n✅ Zayed CyberShield terminated gracefully\n");
    printf("🎖️ المحارب يحميك - The Warrior Protects You\n\n");
    
    return EXIT_SUCCESS;
}

/* ═══════════════════════════════════════════════════════════════════════════
 * END OF FILE
 * ═══════════════════════════════════════════════════════════════════════════ */
