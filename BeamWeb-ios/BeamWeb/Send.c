//
//  Send.c
//  BeamWeb
//
//  Created by Andrew Duffy on 4/8/16.
//  Copyright © 2016 Andrew Duffy. All rights reserved.
//

#include "Send.h"
#include <arpa/inet.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdbool.h>
#include <netdb.h>
#include <string.h>

// Ping the current test
int send_ping(const char *text, const char *host, int port) {
    printf("Sending URL \"%s\" to host %s:%d\n", text, host, port);
    size_t len = strlen(text);
    struct sockaddr_in server;
    int fd, err;

    memset(&server, 0, sizeof server);
    fd = socket(AF_INET, SOCK_STREAM, 0);
    
    err = inet_aton(host, &server.sin_addr);
    if (err < 0) {
        printf("Failing in aton\n");
        return err;
    }
    
    // connect to the remote.
    server.sin_port = htons(port); // client port 6000
    
    // connect to server
    err = connect(fd, (struct sockaddr*)&server, sizeof(struct sockaddr_in));
    if (err < 0) {
        printf("Failing in connect\n");
        return err;
    }
    // Send the thing
    size_t sent = send(fd, text, (size_t)len, 0);
    if (sent < len) {
        printf("Shit! We only sent %d of %d bytes to the host\n", sent, len);
        return -1;
    }
    printf("Send successful\n");
    return 0;
}