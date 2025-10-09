Name:           te-metrics-collector
Version:        1.0.0
Release:        1%{?dist}
Summary:        TE Metrics Collector Service

License:        Proprietary
URL:            https://github.com/ambatiy/ssr-te-metrics-collector
Source0:        te-metrics-collector.sh
Source1:        te-metrics-collector.service

BuildArch:      noarch
BuildRequires:  systemd
Requires:       systemd

%description
A daemon that watches 128T-mist-agent for config-change events, samples
various pcli stats every 7s until health is confirmed, then uploads logs.

%prep
# no unpacking needed

%build
# no build step

%install
# 1 & 2 & 3: copy script and make executable
install -d %{buildroot}/usr/local/bin
install -m 0755 %{SOURCE0} %{buildroot}/usr/local/bin/te-metrics.sh

# 4: copy service unit into /etc/systemd/system
install -d %{buildroot}/etc/systemd/system
install -m 0644 %{SOURCE1} %{buildroot}/etc/systemd/system/te-metrics.service

%post
# 5 & 6: enable & start the service immediately
/bin/systemctl daemon-reload
/bin/systemctl enable te-metrics.service
/bin/systemctl start  te-metrics.service

%preun
# stop & disable on uninstall
if [ $1 -eq 0 ] ; then
  /bin/systemctl stop  te-metrics.service
  /bin/systemctl disable te-metrics.service
  /bin/systemctl daemon-reload
fi

%files
/usr/local/bin/te-metrics.sh
%config(noreplace) /etc/systemd/system/te-metrics.service

%changelog
* Thu Oct  9 2025 Yeshwanth Ambati <ambatiy@juniper.net> - 1.0.0-1
- Install script to /usr/local/bin/te-metrics.sh, unit to /etc/systemd/system/te-metrics.service
- Auto-enable and start service on install
