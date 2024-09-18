package main

import (
	"os"
	"os/signal"
	"syscall"
	"time"

	log "github.com/sirupsen/logrus"
)

func main() {
	n := 2 // Interval in seconds
	ticker := time.NewTicker(time.Duration(n) * time.Second)
	defer ticker.Stop()

	// Set up channel to listen for termination signals
	signals := make(chan os.Signal, 1)
	// Catch SIGTERM and SIGINT
	signal.Notify(signals, syscall.SIGTERM, syscall.SIGINT)

	for {
		select {
		case <-ticker.C:

		case sig := <-signals:
			log.Infof("🛑 Received signal: %s, stopping...\n", sig)
			return // Exit the program
		}
	}
}
