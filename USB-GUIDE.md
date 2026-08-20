# Make a ReviveAI Bootable USB

## What you need

- A 64-bit laptop or desktop with at least 4 GB RAM (8 GB recommended)
- One USB flash drive, 8 GB minimum (16 GB recommended)
- A second working computer to prepare the USB
- `reviveai-amd64.iso` from the ReviveAI OS GitHub Actions artifact/release
- **Rufus** on Windows, or **balenaEtcher** on Windows/macOS/Linux

Everything currently on the USB drive will be erased.

## Windows: Rufus (recommended)

1. Download and open Rufus from <https://rufus.ie/>.
2. Insert the USB flash drive.
3. Under **Device**, select that USB drive. Double-check its capacity and name.
4. Under **Boot selection**, choose **Disk or ISO image**, click **Select**, and
   select `reviveai-amd64.iso`.
5. Leave **Partition scheme** as `GPT` for most computers made after 2012.
   Choose `MBR` for an older legacy-BIOS computer.
6. Leave the remaining settings at their defaults and click **Start**.
7. If Rufus asks for ISO mode or DD mode, choose **ISO Image mode** first.
8. Confirm that Rufus may erase the USB and wait until the status says **Ready**.
9. Safely eject the USB.

## Windows/macOS/Linux: balenaEtcher

1. Download Etcher from <https://etcher.balena.io/>.
2. Choose **Flash from file** and select `reviveai-amd64.iso`.
3. Choose the USB drive. Verify that you did not select another external disk.
4. Select **Flash** and wait for writing and verification to finish.

## Linux command line

First identify the USB device with `lsblk`. Then write the ISO to the whole
device—not to a numbered partition:

```bash
sudo dd if=reviveai-amd64.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Replace `/dev/sdX` with the verified USB device. This command permanently
overwrites the selected device.

## Boot the old computer

1. Insert the prepared USB while the old computer is powered off.
2. Power it on and repeatedly tap its boot-menu key:
   - Dell: `F12`
   - HP: `F9` or `Esc`
   - Lenovo: `F12` or the Novo button
   - Acer: `F12`
   - ASUS: `Esc`
   - Toshiba: `F12`
3. Select the entry named for the USB drive. Prefer the `UEFI` entry when shown.
4. If it refuses to boot, enter BIOS/UEFI setup and temporarily disable Secure
   Boot. Very old computers may also require Legacy/CSM boot and an MBR USB.
5. Choose the ReviveAI live option and allow several minutes for the first boot.

## First-time AI setup

The image intentionally does not redistribute a multi-gigabyte AI model. After
booting, connect to the internet once and run:

```bash
sudo /opt/reviveai/bin/download-model
sudo systemctl restart reviveai
```

Then open <http://127.0.0.1:8080> in Firefox. After the model is downloaded,
the assistant itself can run offline.

## Persistence warning

A normal live USB forgets downloaded models and settings after reboot. For the
first test, boot the USB and confirm the desktop, Wi-Fi, sound, and hardware
report work. For regular use, install ReviveAI to the internal drive or create
a Linux Live persistence partition labeled `persistence` with a
`persistence.conf` file containing `/ union`.

Because persistence tools vary by USB writer, internal-drive installation is
the recommended permanent setup for nontechnical users.

## Expected performance

- Less than 4 GB RAM or a 32-bit CPU: not supported
- 4–6 GB RAM: 1.7B Q4 model; slow, short answers
- 8–12 GB RAM: 3B Q4 model; useful basic assistant
- 16 GB RAM: 7B Q4 model; better writing and reasoning

An older dual-core CPU may produce roughly one to three tokens per second. A
solid-state drive improves boot and loading time substantially, but it does not
materially increase text-generation speed.
