import os
import streamlit as st

st.set_page_config(page_title="Cloud Run CICD Test", page_icon="🚀")
st.title("✅ Cloud Run CI/CD Test (Streamlit)")
st.write("如果你看到這頁，代表 Docker + Cloud Build + Cloud Run 自動部署成功！")

st.subheader("環境資訊")
st.code({
    "PORT": os.getenv("PORT", "8080"),
    "GCP_PROJECT": os.getenv("GCP_PROJECT", ""),
    "K_SERVICE": os.getenv("K_SERVICE", ""),
    "K_REVISION": os.getenv("K_REVISION", ""),
}, language="json")

st.subheader("互動測試2")
name = st.text_input("你的名字", "dino")
st.success(f"Hello, {name}! 🚀") 