# BSY 代理配置中心（静态网站）

一个**移动端友好的免费代理配置下载站**。通过 GitHub Actions **定时自动同步** GitLab 云端最新配置，任何设备（含手机）访问网站即可看到最新配置并一键下载。

## 功能
- 📱 **手机/电脑通用**：响应式页面，大按钮触控友好
- 🔄 **自动更新**：GitHub Actions 每 4 小时同步一次最新配置
- 🎨 **高端简洁风**：嵌入你的 LOGO（bsywqx.github.io/logo.png）
- ⬇ **多格式下载**：Clash / Xray / Hysteria / Hysteria2 / sing-box / NaiveProxy

## 目录结构
```
_proxy_config_site/
├── index.html              # 主页面（移动端优先）
├── update.ps1              # 配置拉取脚本（跨平台 PowerShell）
├── .nojekyll               # 让 GitHub Pages 正常托管
├── config/                 # 同步好的配置（自动更新）
│   ├── clash.meta_config.yaml
│   ├── Xray_config.json
│   ├── hysteria_config.json
│   ├── hysteria2_config.json
│   ├── singbox_config.json
│   ├── naiveproxy_config.json
│   └── .last_update        # 最近同步时间戳
└── .github/workflows/
    └── update-config.yml   # 定时自动更新工作流
```

## 部署步骤（GitHub Pages）

1. **建仓库**：在 GitHub 新建一个仓库（如 `proxy-config`），设为 **Public**
2. **上传文件**：把 `_proxy_config_site/` 里的**所有内容**（含隐藏的 `.nojekyll`、`.github/`）上传到仓库根目录
3. **开启 Pages**：仓库 `Settings → Pages → Source` 选 `Deploy from a branch`，分支选 `main`，目录 `/ (root)`，保存
4. **手动同步一次**：`Actions → 自动更新代理配置 → Run workflow`（或直接 push 触发）
5. **完成**：稍等几分钟，访问 `https://你的用户名.github.io/仓库名/` 即可

## 更新频率调整
编辑 `.github/workflows/update-config.yml` 里的 `cron`：
- 每 4 小时：`0 */4 * * *`
- 每 6 小时：`0 */6 * * *`
- 每天一次：`0 2 * * *`

## 配置源
配置来自 GitLab 云端镜像（`Alvin9999/PAC`），通过 `gitlabip.xyz` 和 `gitlab.com/free9999/ipupdate` 两个源拉取，自动回退。

## 法律声明
仅供学习与技术研究，请遵守所在地法律法规。

© Masud