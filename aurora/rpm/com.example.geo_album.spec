%include %{_sourcedir}/defines.inc

%global __provides_exclude_from ^%{_datadir}/%{name}/lib/.*$
%global __requires_exclude %{_flutter_excludes}

Name: %{orgName}.%{appName}%{?flavor}
Summary: A simple project that show photo wia gps on map.
Version: 1.0.0
Release: 1
License: BSD-3-Clause
Source0: %{name}-%{version}.tar.zst

BuildRequires: cmake
BuildRequires: ninja
BuildRequires: pkgconfig(Qt5Core)

%description
%{summary}.

%prep
%autosetup

%build
%cmake -GNinja -DCMAKE_BUILD_TYPE=%{_flutter_build_type} -DPSDK_VERSION=%{_flutter_psdk_version} -DPSDK_MAJOR=%{_flutter_psdk_major} -DFLUTTER_PROJECT_NAME=%{name}
%ninja_build

%install
%ninja_install

%files
%{_bindir}/%{name}
%{_datadir}/%{name}/*
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
