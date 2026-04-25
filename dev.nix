{ pkgs, ... }: {
  channel = "stable-24.11";

  packages = [
    pkgs.qemu
    pkgs.htop
    pkgs.cloudflared
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.wget
    pkgs.git
    pkgs.python3
  ];

  idx.workspace.onStart = {
    qemu = ''
      set -e

      # =========================
      # One-time cleanup
      # =========================
      if [ ! -f /home/user/.cleanup_done ]; then
        rm -rf /home/user/.gradle/* /home/user/.emu/* || true
        find /home/user -mindepth 1 -maxdepth 1 \
          ! -name 'idx-windows-gui' \
          ! -name '.cleanup_done' \
          ! -name '.*' \
          -exec rm -rf {} + || true
        touch /home/user/.cleanup_done
      fi

      # =========================
      # Paths
      # =========================

      SKIP_QCOW2_DOWNLOAD=0

      VM_DIR="$HOME/qemu"
      RAW_DISK="$VM_DIR/windows.qcow2"
      WIN_ISO="$VM_DIR/automic11.iso"
      VIRTIO_ISO="$VM_DIR/virtio-win.iso"
      NOVNC_DIR="$HOME/noVNC"

     
     OVMF_DIR="$HOME/qemu/ovmf"
     OVMF_CODE="$OVMF_DIR/OVMF_CODE.fd"
     OVMF_VARS="$OVMF_DIR/OVMF_VARS.fd"

     mkdir -p "$OVMF_DIR"

     # =========================
     # Download OVMF firmware if missing
     # =========================
     if [ ! -f "$OVMF_CODE" ]; then
        echo "Downloading OVMF_CODE.fd..."
        wget -O "$OVMF_CODE" \
          https://qemu.weilnetz.de/test/ovmf/usr/share/OVMF/OVMF_CODE.fd
        else
          echo "OVMF_CODE.fd already exists, skipping download."
     fi

     if [ ! -f "$OVMF_VARS" ]; then
       echo "Downloading OVMF_VARS.fd..."
       wget -O "$OVMF_VARS" \
         https://qemu.weilnetz.de/test/ovmf/usr/share/OVMF/OVMF_VARS.fd
     else
       echo "OVMF_VARS.fd already exists, skipping download."
     fi

      mkdir -p "$VM_DIR"i

      # =========================
      # Handle QCOW2 Disk (Download or Create 100GB)
      # =========================
      if [ "$SKIP_QCOW2_DOWNLOAD" -ne 1 ]; then
        if [ ! -f "$RAW_DISK" ]; then
          echo "Downloading pre-made QCOW2 disk..."
          wget -O "$RAW_DISK" https://bit.ly/45hceMn
        fi
      fi

      # Integrated from your second code: Create 100GB disk if it doesn't exist
      if [ ! -f "$RAW_DISK" ]; then
        echo "💽 Creating 100GB virtual disk..."
        qemu-img create -f qcow2 "$RAW_DISK" 100G
      else
        echo "Disk image already exists, skipping creation."
      fi
      

      # =========================
      # Download Windows ISO if missing
      # =========================
      if [ ! -f "$WIN_ISO" ]; then
        echo "Downloading Windows ISO..."
        wget -O "$WIN_ISO" \
          https://github.com/kmille36/idx-windows-gui/releases/download/1.0/automic11.iso
      else
        echo "Windows ISO already exists, skipping download."
      fi
