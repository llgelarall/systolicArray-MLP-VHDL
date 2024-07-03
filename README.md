# Systolic Array-based Inference Engine for MLP on Iris Dataset

This project builds upon the previous MLP implementation for the Iris dataset by developing an inference engine using Systolic Arrays. The aim is to accelerate the MLP inference process and improve efficiency.

## Project Description

### Overview

- The MLP trained in the previous project is used here for inference.
- A Systolic Array architecture is implemented to accelerate the computation.
- The engine uses floating-point numbers and is designed in a generic and scalable manner.
- The Systolic Array is implemented using VHDL and is not synthesizable.

### Systolic Array Implementation

1. **Architecture Design**:
    - The Systolic Array is designed to perform the matrix multiplication required for MLP inference.
    - The design includes a pipeline architecture to optimize the computation flow.

2. **Forward Propagation**:
    - The computation for each neuron in the hidden layer 1:
        ```text
        z11 = w11 * x1 + w21 * x2 + w31 * x3 + w41 * x4 + b1
        z12 = w12 * x1 + w22 * x2 + w32 * x3 + w42 * x4 + b2
        z13 = w13 * x1 + w23 * x2 + w33 * x3 + w43 * x4 + b3
        z14 = w14 * x1 + w24 * x2 + w34 * x3 + w44 * x4 + b4
        ```
    - Apply ReLU activation function:
        ```text
        h11 = ReLU(z11)
        h12 = ReLU(z12)
        h13 = ReLU(z13)
        h14 = ReLU(z14)
        ```
    - The computation for each neuron in the hidden layer 2:
        ```text
        z21 = w51 * h11 + w61 * h12 + w71 * h13 + w81 * h14 + b5
        z22 = w52 * h11 + w62 * h12 + w72 * h13 + w82 * h14 + b6
        z23 = w53 * h11 + w63 * h12 + w73 * h13 + w83 * h14 + b7
        z24 = w54 * h11 + w64 * h12 + w74 * h13 + w84 * h14 + b8
        ```
    - Apply ReLU activation function:
        ```text
        h21 = ReLU(z21)
        h22 = ReLU(z22)
        h23 = ReLU(z23)
        h24 = ReLU(z24)
        ```
    - The computation for each neuron in the output layer:
        ```text
        z31 = w91 * h21 + w101 * h22 + w111 * h23 + w121 * h24 + b9
        z32 = w92 * h21 + w102 * h22 + w112 * h23 + w122 * h24 + b10
        z33 = w93 * h21 + w103 * h22 + w113 * h23 + w123 * h24 + b11
        ```
    - Apply ReLU activation function:
        ```text
        y1 = ReLU(z31)
        y2 = ReLU(z32)
        y3 = ReLU(z33)
        ```

3. **Data Orchestration**:
    - Data orchestration is managed to ensure efficient data flow through the Systolic Array.

### Results

- The Systolic Array-based inference engine achieved an accuracy of 14 out of 15 (approximately 93%) on the test set.

## Conclusion

This project demonstrates the implementation of a Systolic Array-based inference engine for the MLP trained on the Iris dataset. The VHDL implementation provides a hardware-accelerated approach to MLP inference, achieving high accuracy and efficient computation.
