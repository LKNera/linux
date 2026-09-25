#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

int main() {
    // 1. First Fork: Create the child process
    pid_t pid1 = fork();

    if (pid1 < 0) {
        perror("First fork failed");
        return 1;
    }

    if (pid1 == 0) {
        // Inside First Child: Fork immediately again to create a grandchild
        pid_t pid2 = fork();

        if (pid2 < 0) {
            perror("Second fork failed");
            exit(1);
        }

        if (pid2 == 0) {
            // Inside Grandchild Process: Launch Firefox with the URL
            // Arguments: (binary, command, URL, NULL)
            execlp("firefox", "firefox", "https://example.com", NULL);
            
            // If execlp fails (e.g., Firefox isn't installed)
            perror("Failed to launch Firefox");
            exit(1);
        }

        // Inside First Child: Exit immediately!
        // This makes the grandchild an orphan, so Linux PID 1 adopts it.
        // Adopting it guarantees it gets cleaned up automatically on exit.
        exit(0); 
    }

    // Inside Main Parent Process: Wait *only* for the first child to exit.
    // Since the first child exits instantly, this wait takes 0 seconds.
    waitpid(pid1, NULL, 0);

    // 2. The program has now completely forgotten Firefox.
    printf("Firefox launched with URL in the background!\n");
    printf("No zombie processes will be created.\n");

    // Simulate your C program running for a very long time
    printf("Main program running indefinitely... (Press Ctrl+C to stop)\n");
    while (1) {
        sleep(10);
    }

    return 0;
}

