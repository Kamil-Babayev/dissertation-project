import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
    stages: [
        { duration: '30s', target: 20 },
        { duration: '1m', target: 50 },
        { duration: '30s', target: 0 },
    ],
};

export default function () {
    const url = __ENV.TARGET_URL || 'http://localhost:8081/deposit';
    const payload = JSON.stringify({
        account_id: "acc_12345",
        iban: "DE12345678901234567890",
        amount: 1000.50
    });

    const params = {
        headers: { 'Content-Type': 'application/json' },
    };

    let res = http.post(url, payload, params);
    
    check(res, {
        'status is 200': (r) => r.status === 200,
        'transaction_id present': (r) => {
            if (r.status !== 200) return false; 
            
            try {
                const body = r.json();
                return body !== null && body.transaction_id !== undefined;
            } catch (e) {
                return false;
            }
        },
    });

    sleep(0.1);
}
