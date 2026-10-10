# entities-multiplayer-fabric-cycle-tests

Smoke-test scripts that check one fabric cycle's pass criteria end to end against live infrastructure.

## What it is for

Each script is a minimal scene-tree script that connects to the deployed services, checks its cycle's pass criteria, and exits zero on pass and non-zero on fail with the reason on standard error.

## Run

```sh
godot --script <cycle>/<script>.gd
```

The engine must be a double-precision build with WebTransport support.

## Licence

MIT. See [LICENSE](LICENSE).
