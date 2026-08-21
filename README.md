# ReviveAI OS

ReviveAI OS turns an aging 64-bit PC into a private, offline AI assistant. It is
an intentionally small layer for antiX or minimal Debian—not a heavyweight
container stack and not a new Linux distribution (yet).

The first release installs `llama.cpp`, selects a quantized model appropriate
for the machine's memory, and runs the built-in browser UI as a local service.

## What it is for

- Reuse older laptops and desktops instead of discarding them
- Give older or nontechnical users a simple local assistant
- Keep chats and documents on the machine
- Work without a subscription or permanent internet connection
- Trade response speed for low hardware cost and long equipment life

## Minimum useful hardware

| Hardware | Experience | Default model class |
|---|---|---|
| 64-bit CPU, 4 GB RAM | Slow but usable for short questions | 1–2B, Q4 |
| 64-bit CPU, 8 GB RAM | Practical basic assistant | 3B, Q4 |
| 64-bit CPU, 16 GB RAM | Better writing and reasoning | 7B, Q4 |
| Less than 4 GB or 32-bit CPU | Not recommended | None |

CPU-only generation on a very old dual-core machine may be only 1–3 tokens per
second. That is still useful for patient, low-volume users, but it will not feel
like a cloud chatbot.

## Recommended base system

Install **antiX 64-bit** or **Debian 64-bit with a lightweight desktop**. The
installer currently supports Debian-family systems using `apt`. Damn Small
Linux is not the default because its 32-bit/legacy focus conflicts with modern
local-model runtimes.

## Quick start

```bash
git clone https://github.com/john8280/reviveai-os.git
cd reviveai-os
./hardware-check.sh
sudo ./install.sh
```

The installer:

1. Verifies a 64-bit CPU and available memory.
2. Installs only the build/runtime packages needed by `llama.cpp`.
3. Builds an optimized local `llama-server`.
4. Offers a model tier based on RAM.
5. Installs a locked-down systemd service bound to `127.0.0.1`.

After installation, open <http://127.0.0.1:8080>.

## Bootable USB image

See the complete [USB creation and boot guide](USB-GUIDE.md) for Rufus, Etcher,
BIOS boot keys, first-time model setup, and persistence.

Tagged releases can include `reviveai-amd64.iso`, a Debian-based hybrid image
that boots from USB or DVD. Write it with Rufus, balenaEtcher, GNOME Disks, or:

```bash
sudo dd if=reviveai-amd64.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

**Double-check `/dev/sdX`; this command overwrites the selected drive.** The
image boots into a lightweight LXDE desktop and opens first-run model setup.

To build the image yourself on Debian/Ubuntu:

```bash
sudo ./image/build-iso.sh
```

The boot option includes Linux Live persistence support. A persistence partition
is needed if you want downloaded models and settings to survive reboot while
running directly from USB. Installing ReviveAI to the computer's internal drive
does not require USB persistence.

## Model installation

Model downloads are intentionally separate so the project does not silently
download several gigabytes. Run:

```bash
sudo /opt/reviveai/bin/download-model
sudo systemctl restart reviveai
```

The downloader recommends a tier from total memory and asks before downloading.
Advanced users can place any GGUF model at `/opt/reviveai/models/assistant.gguf`.

## Security

The service listens only on the local computer. Do not expose port 8080 to the
internet. ReviveAI does not grant the model shell, file, or administrator access.
Those capabilities require a separate, explicit permissions design.

## Roadmap

- Bootable antiX/Debian-derived installer image
- First-boot accessibility setup and large-text mode
- Local document library with opt-in retrieval
- Voice input/output for users who struggle with keyboards
- Hardware compatibility database and benchmark submission
- Signed releases and reproducible image builds

## Support the project

ReviveAI OS is an independent open-source experiment. Donations help cover test
hardware, replacement drives, model testing, documentation, and accessibility work.

[Visit the project website](https://reviveai-os.john8280.chatgpt.site) ·
[Support ReviveAI OS on Ko-fi](https://ko-fi.com/V7V4RAK9C)

## License

ReviveAI OS is licensed under the MIT License. Models have their own licenses;
review a model's license before redistribution or commercial use.
