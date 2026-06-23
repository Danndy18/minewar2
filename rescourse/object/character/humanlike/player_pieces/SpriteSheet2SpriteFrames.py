import os
import sys
import shutil
import tkinter as tk
from tkinter import ttk, messagebox, filedialog
from PIL import Image

VERSION = "v1.1.0"


ANIM_LAYOUT = [
    ("上半身-站立-空手", 1),
    ("上半身-站立-持物", 1),
    ("上半身-行走", 6),
    ("上半身-轻攻击-前摇", 2),
    ("上半身-轻攻击-生效区间", 3),
    ("上半身-轻攻击-后摇", 3),
    ("上半身-重攻击-前摇", 3),
    ("上半身-重攻击-生效区间", 2),
    ("上半身-重攻击-后摇", 3),
    ("上半身-蓄力-前摇", 5),
    ("上半身-蓄力-生效区间", 2),
    ("上半身-蓄力-后摇", 2),
    ("上半身-抬手", 3),
    ("上半身-单手抬手", 1),
    ("上半身-单手抬手-挥舞", 3),
    ("上半身-抬手-挥舞", 3),
    ("下半身-停滞", 1),
    ("下半身-行走", 6),
]

FRAME_W = 64
FRAME_H = 32
COLS = 6
SPEED = 5.0


def get_tool_dir():
    if getattr(sys, 'frozen', False):
        return os.path.dirname(sys.executable)
    return os.path.dirname(os.path.abspath(__file__))


def find_project_root(start_dir):
    d = start_dir
    while True:
        if os.path.isfile(os.path.join(d, "project.godot")):
            return d
        parent = os.path.dirname(d)
        if parent == d:
            return None
        d = parent


def to_res_path(absolute_path, project_root):
    rel = os.path.relpath(absolute_path, project_root)
    return "res://" + rel.replace("\\", "/")


def _make_outline_png(src_png, dest_png):
    img = Image.open(src_png).convert("RGBA")
    pixels = img.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if a > 0:
                pixels[x, y] = (0, 0, 0, 255)
    img.save(dest_png, "PNG")


def _cut_outline_png(src_png, dest_png):
    img = Image.open(src_png).convert("RGBA")
    pixels = img.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if r == 0 and g == 0 and b == 0 and a > 0:
                pixels[x, y] = (0, 0, 0, 0)
    img.save(dest_png, "PNG")


def generate_tres(png_path, tres_path, parent=None):
    if not os.path.isfile(png_path):
        return False

    dir_path = os.path.dirname(png_path)
    basename = os.path.splitext(os.path.basename(png_path))[0]

    project_root = find_project_root(dir_path)
    if project_root:
        png_rel = to_res_path(png_path, project_root)
    else:
        png_rel = f"res://{os.path.basename(png_path)}"

    lines = []
    lines.append('[gd_resource type="SpriteFrames" format=3]')
    lines.append("")
    lines.append(f'[ext_resource type="Texture2D" path="{png_rel}" id="1_png"]')
    lines.append("")

    sub_count = 0
    sub_ids = []
    for row, (_, frame_count) in enumerate(ANIM_LAYOUT):
        for col in range(frame_count):
            sub_count += 1
            sub_id = f"AtlasTexture_{sub_count:04d}"
            x = col * FRAME_W
            y = row * FRAME_H
            lines.append(f'[sub_resource type="AtlasTexture" id="{sub_id}"]')
            lines.append(f'atlas = ExtResource("1_png")')
            lines.append(f"region = Rect2({x}, {y}, {FRAME_W}, {FRAME_H})")
            lines.append("")
            sub_ids.append(sub_id)

    anim_entries = []
    idx = 0
    for row, (name, frame_count) in enumerate(ANIM_LAYOUT):
        frames_list = []
        for f in range(frame_count):
            frames_list.append(
                f'{{"duration": 1.0, "texture": SubResource("{sub_ids[idx+f]}")}}'
            )
        frames_json = ",\n".join(frames_list)
        anim_entry = f"""{{
"frames": [{frames_json}],
"loop": true,
"name": &"{name}",
"speed": {SPEED}
}}"""
        anim_entries.append(anim_entry)
        idx += frame_count

    lines.append("[resource]")
    lines.append(f"animations = [\n{',\n'.join(anim_entries)}\n]")

    with open(tres_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    return tres_path, sub_count


def process_files(paths, status_label, root):
    tool_dir = get_tool_dir()
    success_count = 0
    fail_count = 0
    last_name = ""

    for p in paths:
        try:
            name_no_ext = os.path.splitext(os.path.basename(p))[0]
            folder = os.path.join(tool_dir, name_no_ext)
            os.makedirs(folder, exist_ok=True)

            src_png = os.path.join(folder, f"{name_no_ext}_source.png")
            shutil.copy2(p, src_png)

            main_png = os.path.join(folder, f"{name_no_ext}.png")
            outline_png = os.path.join(folder, f"{name_no_ext}_outline.png")

            _cut_outline_png(src_png, main_png)
            _make_outline_png(src_png, outline_png)

            generate_tres(main_png, os.path.join(folder, f"{name_no_ext}.tres"), parent=root)
            generate_tres(outline_png, os.path.join(folder, f"{name_no_ext}_outline.tres"), parent=root)

            last_name = f"{name_no_ext}.tres + {name_no_ext}_outline.tres"
            success_count += 1
        except Exception as e:
            fail_count += 1
            messagebox.showerror("错误", str(e), parent=root)

    if success_count > 0:
        msg = f"已生成 {last_name}"
        status_label.config(text=msg, foreground="#22c55e")
    if fail_count > 0:
        msg = f"其中 {fail_count} 个文件格式不对"
        status_label.config(text=msg, foreground="#ef4444")
    if success_count == 0 and fail_count == 0:
        status_label.config(text="没有处理任何文件", foreground="#f59e0b")


def build_gui(use_dnd=False):
    if use_dnd:
        from tkinterdnd2 import TkinterDnD
        root = TkinterDnD.Tk()
    else:
        root = tk.Tk()

    root.title(f"精灵表 → 图包 {VERSION}")
    root.geometry("480x280")
    root.minsize(400, 240)
    root.configure(bg="#1a1a2e")

    root.columnconfigure(0, weight=1)
    root.rowconfigure(0, weight=1)

    main_frame = tk.Frame(root, bg="#1a1a2e")
    main_frame.grid(row=0, column=0, sticky="nsew", padx=20, pady=20)

    main_frame.columnconfigure(0, weight=1)
    main_frame.rowconfigure(0, weight=0)
    main_frame.rowconfigure(1, weight=1)
    main_frame.rowconfigure(2, weight=0)
    main_frame.rowconfigure(3, weight=0)

    header = tk.Label(
        main_frame,
        text="SpriteSheet → SpriteFrames",
        font=("Segoe UI", 16, "bold"),
        bg="#1a1a2e",
        fg="#e2e8f0",
    )
    header.grid(row=0, column=0, pady=(0, 16))

    drop_frame = tk.Frame(
        main_frame,
        bg="#16213e",
        highlightbackground="#0f3460",
        highlightthickness=2,
        relief="solid",
    )
    drop_frame.grid(row=1, column=0, sticky="nsew")
    drop_frame.columnconfigure(0, weight=1)
    drop_frame.rowconfigure(0, weight=1)

    inner = tk.Frame(drop_frame, bg="#16213e")
    inner.place(relx=0.5, rely=0.5, anchor="center")

    drop_icon = tk.Label(
        inner,
        text="🎯",
        font=("Segoe UI", 36),
        bg="#16213e",
        fg="#e2e8f0",
    )
    drop_icon.pack()

    drop_label = tk.Label(
        inner,
        text="将精灵表 PNG 拖放到此处",
        font=("Segoe UI", 12),
        bg="#16213e",
        fg="#94a3b8",
    )
    drop_label.pack(pady=(4, 0))

    sub_label = tk.Label(
        inner,
        text="自动生成 主图包 + 描边图包（18 种动画 / 64×32 固定布局）",
        font=("Segoe UI", 9),
        bg="#16213e",
        fg="#64748b",
    )
    sub_label.pack(pady=(2, 0))

    if use_dnd:
        from tkinterdnd2 import DND_FILES
        status_label = tk.Label(
            main_frame,
            text="等待文件…",
            font=("Segoe UI", 10),
            bg="#1a1a2e",
            fg="#64748b",
        )
        status_label.grid(row=2, column=0, pady=(12, 0))

        def on_drop(event):
            raw = event.data.strip().strip("{}")
            paths = [p.strip() for p in raw.split() if p.strip()]
            process_files(paths, status_label, root)

        root.drop_target_register(DND_FILES)
        root.dnd_bind("<<Drop>>", on_drop)

        root.drop_frame = drop_frame
        drop_frame.drop_target_register(DND_FILES)
        drop_frame.dnd_bind("<<Drop>>", on_drop)
    else:
        status_label = tk.Label(
            main_frame,
            text='拖放支持未加载，请使用"选择文件"按钮',
            font=("Segoe UI", 10),
            bg="#1a1a2e",
            fg="#f59e0b",
        )
        status_label.grid(row=2, column=0, pady=(12, 0))

        def browse_file():
            files = filedialog.askopenfilenames(
                title="选择精灵表 PNG",
                filetypes=[("PNG 精灵表", "*.png")],
                parent=root,
            )
            process_files(files, status_label, root)

        browse_btn = tk.Button(
            main_frame,
            text="选择文件…",
            command=browse_file,
            font=("Segoe UI", 10),
            bg="#0f3460",
            fg="#e2e8f0",
            activebackground="#1a5276",
            activeforeground="#e2e8f0",
            relief="flat",
            padx=16,
            pady=4,
            cursor="hand2",
        )
        browse_btn.grid(row=3, column=0, pady=(8, 0))

    footer = tk.Label(
        main_frame,
        text="拖入文件 → 自动建文件夹 · 放入主 PNG + 描边 PNG + 对应 .tres",
        font=("Segoe UI", 8),
        bg="#1a1a2e",
        fg="#475569",
    )
    footer.grid(row=4, column=0, pady=(8, 0))

    return root


def main():
    try:
        from tkinterdnd2 import TkinterDnD
        root = build_gui(use_dnd=True)
    except ImportError:
        root = build_gui(use_dnd=False)

    root.mainloop()


if __name__ == "__main__":
    main()
