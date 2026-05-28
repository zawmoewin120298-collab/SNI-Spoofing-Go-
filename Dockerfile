FROM golang:1.21-alpine AS builder

WORKDIR /app

# Source code အားလုံးကို အရင်ယူမည်
COPY . .

# go.mod ဖိုင် မရှိသေးပါက အော်တိုဆောက်ခိုင်းရန်
RUN [ -f go.mod ] || go mod init github.com/aleskxyz/SNI-Spoofing-Go
RUN go mod tidy

# အဓိကအသက် - လက်ရှိ package အောက်က files တွေကို binary အဖြစ် တိုက်ရိုက်စုစည်းဆောက်ခြင်း
RUN CGO_ENABLED=0 GOOS=linux go build -o sni-spoof-proxy .

# Stage 2: lightweight image ဖြင့် မောင်းနှင်ရန်
FROM alpine:latest
RUN apk --no-cache add ca-certificates

WORKDIR /root/
COPY --from=builder /app/sni-spoof-proxy .

# Railway အတွက် Port သတ်မှတ်ချက်
ENV PORT=8080
EXPOSE $PORT

# Proxy ကို မောင်းနှင်မည့် Command အမှန် 
# (-port key နေရာတွင် Railway ပေးသော dynamic $PORT ကို ထည့်သွင်းခြင်း)
CMD ["sh", "-c", "./sni-spoof-proxy -port $PORT"]
