package main

import (
	"encoding/json"
	"log"
	"net/http"
	"time"

	"github.com/k.babayev/dissertation/internal/models"
)

func processDepositHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req models.DepositRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	deposit := req.ToEntity()

	time.Sleep(20 * time.Millisecond)

	time.Sleep(50 * time.Millisecond)

	deposit.Status = "COMPLETED"

	resp := deposit.ToResponse()

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(resp); err != nil {
		log.Printf("Failed to encode response: %v", err)
	}
}

func main() {
	http.HandleFunc("/deposit", processDepositHandler)

	log.Println("Monolith server is running on port 8080...")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
