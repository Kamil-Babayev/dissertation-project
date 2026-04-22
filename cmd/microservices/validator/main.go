package main

import (
	"log"
	"net/http"
	"time"
)

func validateHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	time.Sleep(20 * time.Millisecond)

	w.WriteHeader(http.StatusOK)
}

func main() {
	http.HandleFunc("/validate", validateHandler)
	log.Println("Validator Service running on port 8081...")
	if err := http.ListenAndServe(":8081", nil); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}
