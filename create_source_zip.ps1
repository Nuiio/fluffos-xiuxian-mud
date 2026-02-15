# 创建 Source.zip 压缩包
# 排除 build 目录和 .git 目录

$sourceDir = "."
$destZip = "Source.zip"

# 要包含的文件和文件夹
$items = @(
    ".dockerignore",
    ".gitignore",
    ".vscode",
    "docs",
    "mymud",
    "scripts",
    "supervisor",
    "systemd",
    "docker-compose.yml",
    "DOCKER.md",
    "Dockerfile",
    "nginx.conf",
    "README.md",
    "完整项目文档.md",
    "部署指南.md"
)

# 过滤存在的项目
$existingItems = $items | Where-Object { Test-Path $_ }

if ($existingItems.Count -gt 0) {
    Write-Host "正在压缩以下项目:"
    $existingItems | ForEach-Object { Write-Host "  - $_" }
    
    # 创建压缩包
    Compress-Archive -Path $existingItems -DestinationPath $destZip -Force
    
    Write-Host "`n压缩完成: $destZip"
    Write-Host "文件大小: $((Get-Item $destZip).Length / 1MB) MB"
} else {
    Write-Host "错误: 没有找到要压缩的文件"
}
