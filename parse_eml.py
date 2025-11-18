# 79 80行 修改目录变量e:\mail 创建目录并将邮件存放该目录
#编译成exe文件 pyinstaller --onefile parse_eml.py
import os
import csv
import email
from email.header import decode_header, make_header
import re

def decode_str(s):
    if s is None:
        return ""
    try:
        return str(make_header(decode_header(s)))
    except:
        return s

def clean_body(body):
    # 删除回复或转发内容
    body = re.sub(r"(^|\n)(>.*\n)+", "", body)  # 去除类似“>”的回复内容
    body = re.sub(r"(\n|\r)\s*(On .+ wrote:|\w+@.+ said:).*\n", "", body)  # 删除邮件头部分
    body = re.sub(r"(--.*\n)+", "", body)  # 去除签名部分（常见的 "--"）
    body = re.sub(r"\s*\n\s*", " ", body)  # 去除多余的空行和换行符
    return body.strip()

def extract_body(msg):
    body = ""
    if msg.is_multipart():
        for part in msg.walk():
            content_type = part.get_content_type()
            if content_type == "text/plain":
                charset = part.get_content_charset() or "utf-8"
                try:
                    body += part.get_payload(decode=True).decode(charset, errors="ignore")
                except:
                    pass
            elif content_type == "text/html":
                continue  # 跳过 HTML 格式的内容
    else:
        body = msg.get_payload(decode=True).decode(errors="ignore")
    
    return clean_body(body)

def extract_attachments(msg):
    files = []
    for part in msg.walk():
        filename = part.get_filename()
        if filename:
            files.append(decode_str(filename))
    return "; ".join(files)  # 以分号分隔多个附件

def parse_eml_folder(folder_path, output_csv):
    rows = []
    for root, _, files in os.walk(folder_path):
        for file in files:
            if file.lower().endswith(".eml"):
                eml_path = os.path.join(root, file)
                with open(eml_path, "rb") as f:
                    msg = email.message_from_bytes(f.read())

                from_addr = decode_str(msg.get("From"))
                to_addr = decode_str(msg.get("To"))
                date = decode_str(msg.get("Date"))
                subject = decode_str(msg.get("Subject"))

                body = extract_body(msg)
                attachments = extract_attachments(msg)

                # 确保每封邮件都只占一行
                rows.append([from_addr, to_addr, date, subject, body, attachments])

    # 写入 CSV
    with open(output_csv, "w", newline="", encoding="utf-8-sig") as f:
        writer = csv.writer(f)
        writer.writerow(["发件人", "收件人", "时间", "标题", "正文", "附件名称"])
        writer.writerows(rows)

    print(f"解析完成，共 {len(rows)} 封邮件，已导出到：{output_csv}")

# 设置 EML 文件夹路径和输出 CSV 路径
eml_folder = r"e:\mail"
output_csv = r"e:\mail\emails_output.csv"

parse_eml_folder(eml_folder, output_csv)
