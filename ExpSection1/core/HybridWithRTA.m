% HybridWithRTA implements a high-precision hybrid algorithm for evaluating the zero-balanced Gauss hypergeometric function Ψ(x, y) = 2F1(1, x; 1 + x; -y).
% The algorithm combines the Reciprocal-Argument Transformation Algorithm (RTA) and the Fast Pfaff-based Transformation (FPT) to guarantee optimal numerical stability and efficiency across all parameter regimes.
%
% Inputs:
%   x, y – Scalars or isomorphic matrices (x, y ≥ 0). Both inputs can be scalars, vectors, or matrices. The function automatically applies element-wise evaluation when inputs are arrays of the same size.
%
% Output:
%   z – The computed value(s) of Ψ(x, y) for each input pair. The output matrix Z satisfies z(i, j) = 2F1(1, x(i, j); 1 + x(i, j); -y(i, j)).
%   If either x or y is a scalar, broadcasting is supported so that z(i, j) = 2F1(1, x; 1 + x; -y(i, j)) or z(i, j) = 2F1(1, x(i, j); 1 + x(i, j); -y), respectively.
%
% This implementation achieves machine-level accuracy and demonstrates a performance speedup of over 10^4× compared to traditional approaches, making it highly suitable for large-scale wireless network simulations and real-time signal processing applications.
