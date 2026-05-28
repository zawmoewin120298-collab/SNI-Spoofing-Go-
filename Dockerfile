FROM golang:1.21-alpine

WORKDIR /app

# Source code အားလုံးကို ယူမည်
COPY . .

# go.mod မရှိသေးလျှင် အော်တိုဆောက်ခိုင်းရန်
RUN [ -f go.mod ] || go mod init sni-spoofing-go

# Dependency များကို သန့်စင်ရန်
RUN go mod tidy

# Root folder သို့မဟုတ် subfolder ထဲက .go ဖိုင်တွေကို ရှာပြီး build ဆောက်မည့်ပုံစံ
RUN CGO_ENABLED=0 GOOS=linux go build -o sni-spoof-proxy $(find . -name "*.go" -maxdepth 2 | head -n 1 | xargs dirname) || CGO_ENABLED=0 GOOS=linux go build -o sni-spoof-proxy .

# Railway အတွက် Port သတ်မှတ်ချက်
ENV PORT=8080
EXPOSE $PORT

# ပရိုဂရမ်ကို $PORT ခံပြီး မောင်းနှင်မည်
CMD ["sh", "-c", "./sni-spoof-proxy -port $PORT"]

