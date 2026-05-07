# multiplayer-fabric-cycle-tests

Smoke tests for the Maglev cycles defined in
[`multiplayer-fabric-manuals/decisions/`][adrs]. Each test is a minimal headless
Godot script (`SceneTree`) that verifies one cycle's pass criteria against the
real deployed infrastructure and exits with code 0 on PASS, non-zero on FAIL.

[adrs]: https://github.com/V-Sekai-fire/multiplayer-fabric-manuals/tree/main/decisions

## Layout

```
cycle-1-gateway-handshake/cycle1.gd   # WebTransport/QUIC handshake + datagram round-trip
```

## Running a test

These tests use the assembled V-Sekai engine (must include `module_http3`,
`precision=double`). Build it once via the gitassembly recipe in
[`multiplayer-fabric-merge`][merge], then run:

```bash
godot --headless --script cycle-1-gateway-handshake/cycle1.gd
```

Exit code 0 = pass. Exit code 1 = fail (with a `[CN FAIL]` reason on stderr).

[merge]: https://github.com/V-Sekai-fire/multiplayer-fabric-merge

## Cycle 1 — Godot Client Gateway Handshake

Connects to `gateway.chibifire.com:443` over WebTransport, sends one
`{"action":"ping","id":...,"v":1}` datagram, expects a `{"result":"pong"}`
reply, exits cleanly. Verifies the three Cycle 1 pass criteria:

1. WebTransport/QUIC connection without TLS or handshake error
2. One datagram received (gateway's pong reply)
3. Client exits cleanly (no orphaned process or open port)
