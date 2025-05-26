
# GaussRTA

**Hybrid Algorithm via Reciprocal-Argument Transformation for Efficient Gauss Hypergeometric Evaluation in Wireless Networks**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

GaussRTA offers high-performance MATLAB and C++ implementations for evaluating the zero-balanced Gauss hypergeometric function:

$$
\Psi(x, y) = {}_2F_1(1, x; 1+x; -y),
$$

a fundamental component in analyzing wireless network performance metrics, including SINR coverage and interference modeling. The repository introduces a hybrid algorithm that seamlessly integrates:

* **Pfaff Transformation (FPT)**: Efficient for scenarios where $y < \varphi$ (with $\varphi$ being the golden ratio).
* **Reciprocal-Argument Transformation Algorithm (RTA)**: Exhibits geometric convergence with a rate of $1/y$ for $y > \varphi$.

This hybrid approach dynamically selects the optimal method based on the input parameters, ensuring both computational efficiency and numerical stability across diverse conditions.

---

## Features

* **Hybrid Evaluation Strategy**: Automatically chooses between FPT and RTA based on the value of $y$ to optimize performance.
* **High Precision**: Achieves machine-level accuracy with relative errors typically below $10^{-16}$.
* **Performance Gains**: Demonstrates up to $10^4 \times$ speed-up compared to traditional methods.
* **Versatile Implementations**: Provides both MATLAB scripts and optimized C++ MEX functions.
* **Comprehensive Testing**: Includes scripts to reproduce all experimental results and figures presented in the associated paper.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

For any questions or contributions, please open an issue or submit a pull request on the GitHub repository.

---
