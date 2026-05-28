FROM golang:1.21-alpine AS builder

WORKDIR /app

# Source code အားလုံးကို အရင်ယူမည်
COPY . .

# go.mod ဖိုင် မရှိသေးပါက အော်တိုဆောက်ခိုင်းရန်
RUN [ -f go.mod ] || go mod init github.com/aleskxyz/SNI-Spoofing-Go

# Folder အဆင့်ဆင့်ထဲမှာ ရှိနေတဲ့ Go files တွေကို လိုက်ရှာပြီး dependencies ညှိပေးရန်
RUN go mod tidy

# အဓိကအသက် - မည်သည့် folder ထဲမှာပဲ Go code ရှိရှိ လိုက်ရှာပြီး အောင်မြင်အောင် build ဆောက်မည့်စနစ်
RUN GOOS=linux CGO_ENABLED=0 go build -o sni-spoof-proxy $(find . -name "*.go" -not -path "*/.*" | head -n 1 | xargs dirname) || GOOS=linux CGO_ENABLED=0 go build -o sni-spoof-proxy .

# Stage 2: lightweight image ဖြင့် အပေါ့ပါးဆုံး မောင်းနှင်ရန်
FROM alpine:latest
RUN apk --no-cache add ca-certificates

WORKDIR /root/
COPY --from=builder /app/sni-spoof-proxy .

# Railway အတွက် Port သတ်မှတ်ချက်
ENV PORT=8080
EXPOSE $PORT

# Proxy ကို Railway ရဲ့ $PORT ခံပြီး မောင်းနှင်မည့် Command
CMD ["sh", "-c", "./sni-spoof-proxy -port $PORT"]
