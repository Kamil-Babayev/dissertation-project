package models

import (
	"time"

	"github.com/google/uuid"
)

type DepositRequest struct {
	AccountID string  `json:"account_id"`
	IBAN      string  `json:"iban"`
	Amount    float64 `json:"amount"`
}

type UserDeposit struct {
	ID        string
	AccountID string
	IBAN      string
	Amount    float64
	Status    string
	CreatedAt time.Time
}

type DepositResponse struct {
	TransactionID string `json:"transaction_id"`
	Status        string `json:"status"`
}

func (r *DepositRequest) ToEntity() *UserDeposit {
	return &UserDeposit{
		ID:        uuid.New().String(), // Генерация уникального идентификатора
		AccountID: r.AccountID,
		IBAN:      r.IBAN,
		Amount:    r.Amount,
		Status:    "PENDING",
		CreatedAt: time.Now(),
	}
}

func (d *UserDeposit) ToResponse() *DepositResponse {
	return &DepositResponse{
		TransactionID: d.ID,
		Status:        d.Status,
	}
}
