{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, makeWrapper
, libGL
, libinput
, libseat
, libxkbcommon
, mesa
, stdenv
, systemd
, udev
, vulkan-loader
, wayland
}:

rustPlatform.buildRustPackage rec {
  pname = "halley";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "saltnpepper97";
    repo = "halley";
    rev = "v${version}";
    hash = lib.fakeHash;
  };

  cargoHash = lib.fakeHash;

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    seatd
    libinput
    libxkbcommon
    mesa
    systemd
    udev
    vulkan-loader
    wayland
  ];

  postInstall = ''
    if [ -f packaging/wayland-sessions/halley-session ]; then
      install -Dm755 packaging/wayland-sessions/halley-session \
        $out/bin/halley-session
      substituteInPlace $out/bin/halley-session \
        --replace-fail /usr/bin/env ${stdenv.shell}
    fi

    if [ -f packaging/wayland-sessions/halley.desktop ]; then
      install -Dm644 packaging/wayland-sessions/halley.desktop \
        $out/share/wayland-sessions/halley.desktop
      substituteInPlace $out/share/wayland-sessions/halley.desktop \
        --replace-fail Exec=halley-session Exec=$out/bin/halley-session
    fi

    if [ -f packaging/systemd-user/halley.service ]; then
      install -Dm644 packaging/systemd-user/halley.service \
        $out/lib/systemd/user/halley.service
    fi

    if [ -f packaging/systemd-user/halley-shutdown.target ]; then
      install -Dm644 packaging/systemd-user/halley-shutdown.target \
        $out/lib/systemd/user/halley-shutdown.target
    fi
  '';

  meta = with lib; {
    description = "Spatial Wayland compositor built around infinite workspace navigation";
    homepage = "https://github.com/saltnpepper97/halley";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    mainProgram = "halley";
  };
}
