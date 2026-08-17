# Butane Example

This example demonstrates the Butane snippet submodules and how to combine them into machine configurations using the [`poseidon/ct`](https://registry.terraform.io/providers/poseidon/ct/latest/docs) provider.

## Notes

1. Unlike the other examples, this one renders Ignition configurations only; it does not provision machines or a cluster.
2. The networking submodules configure the same interface and the Zincati submodules are competing update strategies, so a machine must use one of each. The three rendered configurations show valid combinations.
