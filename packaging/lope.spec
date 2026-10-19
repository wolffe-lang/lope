# gump.spec (the maintainer's, gump 43c114d) reshaped for lope. PREPARED,
# NOT PUBLISHED: the binary is the release's static x86-64 build
# (tools/mkstatic), placed in %{_sourcedir} by the packager, as gump's
# spec takes its pre-built binary.
Name:           lope
Version:        0.1.0
Release:        1%{?dist}
Summary:        A frecency directory jumper, in wolf

License:        GPL-3.0-or-later
URL:            https://github.com/wolffe-lang/lope

%description
Directory jumper using frecency. Type directory fragments, land where you meant.
No command prefix required. Supports bash, zsh, fish, fortsh and pelt.
gump, ported to wolf and renamed.

%prep
# Pre-built from source (tools/mkstatic)

%build
# Pre-built from source (tools/mkstatic)

%install
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_datadir}/licenses/%{name}
mkdir -p %{buildroot}%{_datadir}/doc/%{name}
install -Dm755 %{_sourcedir}/lope %{buildroot}%{_bindir}/lope
install -Dm644 %{_sourcedir}/LICENSE %{buildroot}%{_datadir}/licenses/%{name}/LICENSE
install -Dm644 %{_sourcedir}/LICENSE-TRAINING-DATA %{buildroot}%{_datadir}/licenses/%{name}/LICENSE-TRAINING-DATA
install -Dm644 %{_sourcedir}/README.md %{buildroot}%{_datadir}/doc/%{name}/README.md

%post
echo ""
echo "=== lope installed ==="
echo ""
echo "Add to your shell config:"
echo ""
echo "  Bash (~/.bashrc):   eval \"\$(lope init bash)\""
echo "  Zsh (~/.zshrc):     eval \"\$(lope init zsh)\""
echo "  Fish:               lope init fish | source"
echo ""
echo "Then restart your shell or source the file."
echo ""

%files
%license %{_datadir}/licenses/%{name}/LICENSE
%license %{_datadir}/licenses/%{name}/LICENSE-TRAINING-DATA
%doc %{_datadir}/doc/%{name}/README.md
%{_bindir}/lope

%changelog
* Mon Oct 19 2026 mfw <espadonne@outlook.com> - 0.1.0-1
- gump 0.2.7 ported to wolf and renamed lope (lp00)
