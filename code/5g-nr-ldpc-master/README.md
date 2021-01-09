# 5g-nr-ldpc
This library implements a basic version of the 5G NR LDPC code as specified in [TS38.212](https://portal.3gpp.org/desktopmodules/Specifications/SpecificationDetails.aspx?specificationId=3214). The decoder implements the sum-product algorithm and is based on [1].

## Quick start
The file [`ldpcExample.m`](https://github.com/vodafone-chair/5g-nr-ldpc/blob/master/ldpcExample.m) provides a minimal working example of encoding and decoding.

## Features
So far the implementation supports the block lengths `N=[264, 544, 1056, 2176, 4224, 8448]` and code rates `R=[1/3, 1/2, 2/3, 3/4, 5/6]`. Note that the development is not finished. Extension to more code rates and other block lengths are easily possible. The implementation includes the base graphs 1 and 2.

## References 
[1] E. Sharon, S. Litsyn and J. Goldberger, "An efficient message-passing schedule for LDPC decoding," 2004 23rd IEEE Convention of Electrical and Electronics Engineers in Israel, Tel-Aviv, Israel, 2004, pp. 223-226.

\documentclass{article}
\usepackage{amsmath}
\pagestyle{empty}
\begin{document}
\usepackage{tabularx}
\usepackage{booktabs}
\pretolerance=200
\begin{table}
\centering
\begin{tabular}{lll}

\toprule
Symbol & Explanation &Reference Value \\
\midrule
$N_{data}$ & Number of the total transmitted packet for the given data. & 20 \\
$M_{blind}$ & Number of duplicated packets for a single packet in blind retransmission.  \\
$M_{nack}$ & Number of duplicated packets for a single packet in nack-based retransmission.  \\
$M_{XOR}$ & Number of XOR packets in nack-based retransmission.  \\
$R_i$ & Total transmitted round for ith packet in nack-based retransmission.  \\
$k$ &  Number of UE that receiving the service. & 30 \\
 $e_j$ &  Packet error rate for jth UE  \\
 $X_j$ &  R.V. representing the transmitted time for a single packet with error rate $p_j$   \\
 $X$ &  R.V. representing the maximum transmitted time among all of the UEs   \\
 $T_{RTT}$ &  Round trip time in nack-based retransmission 1ms \\
$Rel_{constraint}$ & Reliability constraint for the service. & 0.9999 \\
$L_{constraint}$ & Latency constraint between BS and UEs for the service. & 8ms \\
\bottomrule
\end{tabular}
\caption{\label{tab:table-name}The example for Table 1.}
\end{table}

\end{document}