package main

import (
	"log"
	"net/http"
	"time"
)

func processHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	time.Sleep(50 * time.Millisecond)

	w.WriteHeader(http.StatusOK)
}

func main() {
	http.HandleFunc("/process", processHandler)
	log.Println("Transaction Service running on port 8082...")
	if err := http.ListenAndServe(":8082", nil); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}
