# Streamlit + Cloud Run CI/CD (via Cloud Build)

這是一個最小可行（MVP）的範例，用 **Streamlit** 做網頁，使用 **Docker** 容器，透過 **Cloud Build** 在 push/merge 到 GitHub 的 main 分支後自動 **建置 → 推送 → 部署到 Cloud Run**。

## 專案結構

```text
.
├─ app/
│  └─ streamlit_app.py
├─ Dockerfile
├─ requirements.txt
├─ cloudbuild.yaml
├─ .dockerignore
└─ README.md
```

## 本地測試

```bash
# 方式一：直接執行（需先安裝 Python 3.11+）
pip install -r requirements.txt
streamlit run app/streamlit_app.py

# 方式二：Docker 本地執行
docker build -t streamlit-cicd-demo:local .
docker run -p 8080:8080 streamlit-cicd-demo:local
# 然後瀏覽 http://localhost:8080
```

## 部署前 Cloud Build / Artifact Registry / Cloud Run 設定

1. 啟用 API：
   ```bash
   gcloud services enable run.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com
   ```

2. 建立 Artifact Registry：
   ```bash
   gcloud artifacts repositories create test-repo              --repository-format=docker              --location=asia-east1              --description="Docker repo for CI/CD demo"
   ```

3. 權限（Cloud Build 服務帳號）：到 **IAM** 確認 `PROJECT_NUMBER@cloudbuild.gserviceaccount.com` 具有：
   - `roles/run.admin`
   - `roles/artifactregistry.writer`
   - （若首次部署需要）`roles/iam.serviceAccountUser` 對執行 Cloud Run 的 SA

4. Cloud Build 觸發器（GitHub）：
   - 事件：**Push to a branch**
   - Branch：`^main$`
   - 配置檔：`cloudbuild.yaml`
   - Substitutions 覆寫：`_REGION`, `_REPO`, `_SERVICE`

## 手動（一次性）部署試跑

你也可以不透過觸發器，直接在專案根目錄先丟一發 Cloud Build：
```bash
gcloud builds submit --config cloudbuild.yaml           --substitutions _REGION=asia-east1,_REPO=test-repo,_SERVICE=streamlit-cicd-demo
```

完成後，Cloud Run 服務網址可在主控台或以下指令查到：
```bash
gcloud run services describe streamlit-cicd-demo --region=asia-east1 --format='value(status.url)'
```

## 常見問題

- **部署成功但開不起來？**
  - 確認 Dockerfile 的 `CMD` 使用 `--server.address=0.0.0.0` 與 `--server.port=$PORT`。
  - Cloud Run 預設健康檢查為 HTTP 200；Streamlit 首頁會回 200。
- **權限不足 (403)**：Cloud Build SA 少了 `run.admin` 或 `artifactregistry.writer`。
- **找不到 Repo**：確保 `_REPO` 實際存在於該 region 的 Artifact Registry。

---
Happy shipping! 🚀
