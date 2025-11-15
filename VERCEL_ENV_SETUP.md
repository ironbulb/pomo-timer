# Setting Up Google Calendar Environment Variables on Vercel

## Quick Setup

You need to add 3 environment variables to your Vercel project:

### Method 1: Using Vercel CLI (Recommended - Fastest)

```bash
# Install Vercel CLI if you haven't already
npm i -g vercel

# Set the environment variables
vercel env add GOOGLE_CLIENT_EMAIL
# When prompted, paste: alain-470121@appspot.gserviceaccount.com

vercel env add GOOGLE_PRIVATE_KEY
# When prompted, paste the entire private key including quotes:
# "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC2v/hRJt8jaKTT\n9B+hy8sSywaSbyiVb6aJr2k/06QsIhHb81zFSM8o1DcOaHibTylxmi6DxIMfIfZw\nOXkFuC5G8bVkRQvug9g/HxyI5NtWyKXDiUyuUWUWDSuc/zBbKt/LW3vlt7bGqO71\nR0/W9rKX44CM0tf8faMLjKy00m8z5kVtX67VPkwknWulAps5jTsJHkNKwJ0MBsQT\nUW7CjWimpPByrTc8BTKv5jCBnA5u6EIxChPItJHOChEDiA27F6qI3Rs0ymKYFeF+\nK1WU3C1JPNXGgo+h09xuH/EhjAS17T86sL/7UtFNKoMCzVrVeBKZFwfKVlTOTQd+\nKDFw14LFAgMBAAECggEAB7t4o5gXhnVe8kpPo3ZA55oDqj5UzFVJG/fVirNQPuPL\nAKc740cMTWxyYVZ4aQ3cVh6IS7toMkxhyno5xHGvMwGt1cDnkh9Sal1NIJDRNia8\nyMZuWRYbRuemd6+54o4wogm59xWi7lzCxLeZgEaTLXmdRZgYNmpZBhLdCUcC8+/s\nVFEdA0q7qwapwC/GpJU1h87k+i5RvQPNmhO8t9GpxtMtBaETycQHGjjqr7F8XUlh\nZkrQWQUxxrzEf0cYFWMHY5BpwNdtuBoi7ZTYFT6Zu9RtQaaqWh02Erl9KNbaCFaN\nFL5oIH3MSVUe1fspRN/d7ZjoK8Eh0qnJtniV7gKzEwKBgQC8ukLVoaPgDe2dEMgA\nd4N24taS9yG1RSL7HxzOY3IB1iAfdcOuOtB00y1gJGrC1vb95j4QJBG2YhmpYT0p\nD4OASOWsBzN7yOm6+9A7++r/2GWewwbKal7CCip6vzJQ9H9cSK6kY3wsuD6KWtnd\ne36urVI5Khhf4TvoPbHNpz2f7wKBgQD35Duba8wpIBD7fnOsu+tGzVr1IcXb8uCC\njpF3u1jK/028Ct0FJR9teTls/Wt6ikGdem9Kg9GVdIBJFawiKGtpqnovPEBxni7b\noTthC7ut7OEPFYhrCFkXu3Xb4Xtxtxnw6U+3NbielP1dakz3IFpsxh+iC9qa/bva\n6rVGuU0UiwKBgQCzgzPJQku+9WCbcnfawdNBRPi2p+zfIBjq5igfREYP6x147yom\n0nivdqMFfP4zwAcFcHh+H+DdKyifjQeAw+ngHvafD+ZviqaPna/vLmrT2oCmZ3lR\nFaZ2SPco9C4nBLkUDWpYoOxfGQ0bytjKLApOmjvIdfrjUDkMaYpzQ+2A7wKBgQDy\nu3S2mpaeiny2lrrUIGqguMLhF8Hzvt6iWNIOaM/obpgCkqybth8RBkv58ihFJI5d\nkp7ZWzxlWV+osOUNyYBsRndAO4Jq/tapTzair2eGRlaWe6JKFDGRMImW1jMXRZDM\nOtlI7/yopAF4cHeO4QpKSrJ87ZiQffZtxbfd2eKlQwKBgQCDVEQ0DaIqzwkEY1NI\n5x0dfUCJm8BZ/V8W+juzvd7+g6jd6F9PSsrUdNYm2ry3yz0fgi3Lj1RtimHpMRRa\n9yRPDhxlyu4TaganIyKlrryu3OsIrkmHia48ye2okbnsxDv30yH/iut90V64CQNl\nPoKEwDE8NG+lTrdX8J0PDb5JLg==\n-----END PRIVATE KEY-----\n"

vercel env add GOOGLE_CALENDAR_ID
# When prompted, paste: primary

# Redeploy to apply changes
vercel --prod
```

### Method 2: Using Vercel Dashboard (Web UI)

1. Go to https://vercel.com/dashboard
2. Select your project: `pomo-timer`
3. Go to **Settings** → **Environment Variables**
4. Add each variable:

#### Variable 1: GOOGLE_CLIENT_EMAIL
- **Name**: `GOOGLE_CLIENT_EMAIL`
- **Value**: `alain-470121@appspot.gserviceaccount.com`
- **Environment**: Production, Preview, Development (select all)

#### Variable 2: GOOGLE_PRIVATE_KEY
- **Name**: `GOOGLE_PRIVATE_KEY`
- **Value**: Copy the entire value below including the quotes:
```
"-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC2v/hRJt8jaKTT\n9B+hy8sSywaSbyiVb6aJr2k/06QsIhHb81zFSM8o1DcOaHibTylxmi6DxIMfIfZw\nOXkFuC5G8bVkRQvug9g/HxyI5NtWyKXDiUyuUWUWDSuc/zBbKt/LW3vlt7bGqO71\nR0/W9rKX44CM0tf8faMLjKy00m8z5kVtX67VPkwknWulAps5jTsJHkNKwJ0MBsQT\nUW7CjWimpPByrTc8BTKv5jCBnA5u6EIxChPItJHOChEDiA27F6qI3Rs0ymKYFeF+\nK1WU3C1JPNXGgo+h09xuH/EhjAS17T86sL/7UtFNKoMCzVrVeBKZFwfKVlTOTQd+\nKDFw14LFAgMBAAECggEAB7t4o5gXhnVe8kpPo3ZA55oDqj5UzFVJG/fVirNQPuPL\nAKc740cMTWxyYVZ4aQ3cVh6IS7toMkxhyno5xHGvMwGt1cDnkh9Sal1NIJDRNia8\nyMZuWRYbRuemd6+54o4wogm59xWi7lzCxLeZgEaTLXmdRZgYNmpZBhLdCUcC8+/s\nVFEdA0q7qwapwC/GpJU1h87k+i5RvQPNmhO8t9GpxtMtBaETycQHGjjqr7F8XUlh\nZkrQWQUxxrzEf0cYFWMHY5BpwNdtuBoi7ZTYFT6Zu9RtQaaqWh02Erl9KNbaCFaN\nFL5oIH3MSVUe1fspRN/d7ZjoK8Eh0qnJtniV7gKzEwKBgQC8ukLVoaPgDe2dEMgA\nd4N24taS9yG1RSL7HxzOY3IB1iAfdcOuOtB00y1gJGrC1vb95j4QJBG2YhmpYT0p\nD4OASOWsBzN7yOm6+9A7++r/2GWewwbKal7CCip6vzJQ9H9cSK6kY3wsuD6KWtnd\ne36urVI5Khhf4TvoPbHNpz2f7wKBgQD35Duba8wpIBD7fnOsu+tGzVr1IcXb8uCC\njpF3u1jK/028Ct0FJR9teTls/Wt6ikGdem9Kg9GVdIBJFawiKGtpqnovPEBxni7b\noTthC7ut7OEPFYhrCFkXu3Xb4Xtxtxnw6U+3NbielP1dakz3IFpsxh+iC9qa/bva\n6rVGuU0UiwKBgQCzgzPJQku+9WCbcnfawdNBRPi2p+zfIBjq5igfREYP6x147yom\n0nivdqMFfP4zwAcFcHh+H+DdKyifjQeAw+ngHvafD+ZviqaPna/vLmrT2oCmZ3lR\nFaZ2SPco9C4nBLkUDWpYoOxfGQ0bytjKLApOmjvIdfrjUDkMaYpzQ+2A7wKBgQDy\nu3S2mpaeiny2lrrUIGqguMLhF8Hzvt6iWNIOaM/obpgCkqybth8RBkv58ihFJI5d\nkp7ZWzxlWV+osOUNyYBsRndAO4Jq/tapTzair2eGRlaWe6JKFDGRMImW1jMXRZDM\nOtlI7/yopAF4cHeO4QpKSrJ87ZiQffZtxbfd2eKlQwKBgQCDVEQ0DaIqzwkEY1NI\n5x0dfUCJm8BZ/V8W+juzvd7+g6jd6F9PSsrUdNYm2ry3yz0fgi3Lj1RtimHpMRRa\n9yRPDhxlyu4TaganIyKlrryu3OsIrkmHia48ye2okbnsxDv30yH/iut90V64CQNl\nPoKEwDE8NG+lTrdX8J0PDb5JLg==\n-----END PRIVATE KEY-----\n"
```
- **Environment**: Production, Preview, Development (select all)

#### Variable 3: GOOGLE_CALENDAR_ID
- **Name**: `GOOGLE_CALENDAR_ID`
- **Value**: `primary`
- **Environment**: Production, Preview, Development (select all)

5. Click **Save** for each variable
6. Go to **Deployments** tab and click **Redeploy** on the latest deployment

## Verify Setup

After deploying, test the endpoints:

```bash
# Test calendar endpoint
curl https://pomo-timer-eta.vercel.app/api/gcal

# Test pomodoro timer endpoint (should now show Google Calendar events)
curl https://pomo-timer-eta.vercel.app/api/event
```

## Troubleshooting

If you don't see calendar events:

1. **Make sure you shared your calendar** with the service account email:
   - `alain-470121@appspot.gserviceaccount.com`

2. **Check you have events scheduled** in your Google Calendar

3. **Verify the GOOGLE_CALENDAR_ID**:
   - Use `primary` for your main calendar
   - Or find your calendar ID: Calendar Settings → Integrate calendar → Calendar ID

4. **Check Vercel logs** for any errors:
   - Go to your Vercel project → Deployments → Click on latest → View Function Logs
