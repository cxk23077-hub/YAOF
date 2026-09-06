#!/bin/bash
set -euo pipefail
clear

# X86-specific optimization
sed -i 's,no-mips16 no-lto,no-mips16,g' feeds/packages/libs/libsodium/Makefile

cat > ./package/base-files/files/etc/rc.local <<'EOF'
#!/bin/sh
# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.

if grep -q "Default string" /tmp/sysinfo/model 2>/dev/null; then
    echo "Generic PC" > /tmp/sysinfo/model
fi

PSTATE_STATUS_FILE="/sys/devices/system/cpu/intel_pstate/status"
if [ -f "$PSTATE_STATUS_FILE" ]; then
    if [ "$(cat "$PSTATE_STATUS_FILE")" = "passive" ]; then
        echo "active" > "$PSTATE_STATUS_FILE"
    fi
    for cpu_gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        [ -f "$cpu_gov" ] && echo "powersave" > "$cpu_gov"
    done
    for cpu_epp in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
        [ -f "$cpu_epp" ] && echo "balance_performance" > "$cpu_epp"
    done
fi

exit 0
EOF

# Snapshot/main does not have a stable releases/<version>/profiles.json.
# Do not inject a release Vermagic into a Snapshot build; the build system
# generates the correct kernel/module version information itself.

cp -rf ../PATCH/files ./files

find ./ -name '*.orig' -delete
find ./ -name '*.rej' -delete
exit 0
