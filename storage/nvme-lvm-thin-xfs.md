# NVMe + LVM thin pool XFS storage setup

This setup requires that the disks are of identical size. If not, adjust `thin_pool_size_in_bytes` appropriately.

## setup disks environment variable
```
thin_pool_nvme_disks=(
    /dev/nvme0n1
    /dev/nvme1n1
)
```

## create PV
```
pvcreate ${thin_pool_nvme_disks[@]}
```

## create VG
```
vgcreate vg0 ${thin_pool_nvme_disks[@]}
```

## create thin LV
```
thin_pool_size_in_bytes=$(lvdisplay --units=B | grep 'LV Size' | head -1 | rev | cut -d ' ' -f 3 | rev)
lvcreate -V ${thin_pool_size_in_bytes}B -n default -T /dev/vg0/default-pool
```

## create XFS on thin LV
```
mkfs.xfs -f /dev/vg0/default
```

## mount XFS LV
```
mkdir -p /mnt/lvm/default

thin_lv_uuid=$(blkid | grep /dev/mapper/vg0-default | awk -F '"' '{print $2}')
cat >> /etc/fstab <<EOF

# LVM
UUID=${thin_lv_uuid} /mnt/lvm/default xfs defaults 0 0
EOF

systemctl daemon-reload
mount -a
```

## notes
- be sure to set 'Discard' option to guest VMs with disks inside this XFS LV
- enable `fstrim.timer` or add a cron job to `fstrim /mnt/lvm/default`; do the same inside relevant VM guests as well
