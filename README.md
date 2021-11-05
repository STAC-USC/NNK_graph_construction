## NNK Graph
Matlab source code for the paper: [
Graph Construction from Data using Non Negative Kernel regression (NNK Graphs)](https://arxiv.org/abs/1910.09383).

## Citing this work
```
@article{shekkizhar2020graph,
    title={Graph Construction from Data by Non-Negative Kernel regression},
    author={Sarath Shekkizhar and Antonio Ortega},
    year={2020},
    booktitle={IEEE International Conference on Acoustics, Speech and Signal Processing (ICASSP)}, 
}
```
```
@misc{shekkizhar2019graph,
    title={Graph Construction from Data using Non Negative Kernel regression (NNK Graphs)},
    author={Sarath Shekkizhar and Antonio Ortega},
    year={2019},
    eprint={1910.09383},
    archivePrefix={arXiv},
    primaryClass={cs.LG}
}
```

-----
Update Nov, 2021

## Approximate NNK neighbors
- Solves a batched iterative version of NNK optimization for data points using `knnsearch` function and `pagemtimes` functions.     
- The test demo file provides an example of how the code can be used with feature vectors using a normalized cosine kernel (range in [0,1])  or Gaussian kernel similarity metric.
