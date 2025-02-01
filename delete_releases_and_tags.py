import os
import sys
from datetime import datetime, timedelta, timezone
from github import Auth, Github, GithubException


def get_github_token():
    """从环境变量获取GitHub Token"""
    token = os.getenv("GITHUB_TOKEN")
    if not token:
        print("请设置环境变量 GITHUB_TOKEN")
        sys.exit(1)
    return token


def get_repo(github_instance, repo_name):
    """获取指定仓库"""
    try:
        return github_instance.get_repo(repo_name)
    except GithubException as e:
        print(f"获取仓库失败: {e}")
        sys.exit(1)


def delete_old_releases(repo, days_threshold=7):
    """删除超过指定天数的发行版及其标签"""
    try:
        releases = repo.get_releases()
        if releases.totalCount <= 0:
            print("没有发行版需要处理")
            return

        for release in releases:
            print("datetime.now(timezone.utc)", datetime.now(timezone.utc))
            print("datetime.now(timezone.utc) - timedelta(days=days_threshold)", datetime.now(timezone.utc) - timedelta(days=days_threshold))
            if release.created_at < (
                datetime.now(timezone.utc) - timedelta(days=days_threshold)
            ):
                try:
                    release.delete_release()
                    repo.get_git_ref(f"tags/{release.tag_name}").delete()
                    print(f"发行版 {release.id} 已经被删除(标签: {release.tag_name})")
                except GithubException as e:
                    print(f"删除发行版 {release.id} 失败: {e}")
            else:
                print(
                    f"发行版 {release.id} 未到删除时间, 跳过(标签: {release.tag_name})"
                )
    except GithubException as e:
        print(f"获取发行版失败: {e}")


# 获取GitHub的token，用于后续的API调用身份验证
token = get_github_token()

# 使用获取到的token创建一个认证对象
auth = Auth.Token(token)

# 初始化Github对象，并使用之前创建的认证对象进行身份验证
g = Github(auth=auth)

# 定义需要操作的仓库名称
repo_name = "cricketbrother/lede-actions"

# 通过仓库名称获取具体的仓库对象
repo = get_repo(g, repo_name)

# 删除仓库中旧的发布版本，以保持仓库的整洁和一致性
delete_old_releases(repo, 7)
