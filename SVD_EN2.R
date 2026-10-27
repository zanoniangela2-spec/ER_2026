###############################################
### MANUAL IMPLEMENTATION OF MATRIX COMPLENTION FOR CAUSAL PANEL
###############################################
rm(list = ls())

# Define the initial 4x3 matrix Y
Y <- matrix(c(1, 2, 9,
              2, 7, 5,
              2, 4, 18,
              3, 11, 20), nrow = 4, ncol = 3, byrow = TRUE)
print("Matrix Y:")
print(Y)

# Define Po (mask matrix where missing elements are set to 0)
Po <- Y
Po[1, 1] <- 0
Po[3, 1] <- 0
print("Matrix Po:")
print(Po)

# Define PoT1 (the difference matrix)
PoT1 <- Y - Po
print("Matrix PoT1:")
print(PoT1)

# Set the hyperparameter lambda = 0.5
lambda <- 0.5

###################
# 1) Step 1
###################
L1 <- Po
arg <- Po + PoT1  # arg coincides with Y 

# Singular Value Decomposition
svd_res <- svd(arg)
a <- svd_res$u  # Matrix U (4x3)
S <- svd_res$d  # Vector of singular values (length 3)
b <- svd_res$v  # Matrix V (3x3)

print("Singular values S:")
print(S)

# Soft-thresholding the singular values (Stilda)
Stilda <- S
Stilda[1] <- max(0, S[1] - lambda)
Stilda[2] <- max(0, S[2] - lambda)
Stilda[3] <- max(0, S[3] - lambda)
print("Stilda:")
print(Stilda)

# Reconstruct L2: U * diag(Stilda) * V^T
L2 <- a %*% diag(Stilda) %*% t(b)

# Build PoT2 (4x3 matrix filled with zeros)
PoT2 <- matrix(0, nrow = 4, ncol = 3)
PoT2[1, 1] <- L2[1, 1]
PoT2[3, 1] <- L2[3, 1]

print("PoT1:")
print(PoT1)
print("PoT2:")
print(PoT2)

###################
# 1) Step 2
###################
arg <- Po + PoT2

svd_res <- svd(arg)
a <- svd_res$u
S <- svd_res$d
b <- svd_res$v

print("Singular values S (Step 2):")
print(S)

# Soft-thresholding applied uniformly in step 2
Stilda <- S
Stilda[1] <- max(0, S[1] - lambda)
Stilda[2] <- max(0, S[2] - lambda)
Stilda[3] <- max(0, S[3] - lambda)
print("Stilda (Step 2):")
print(Stilda)

# Reconstruct L3: U * diag(Stilda) * V^T
L3 <- a %*% diag(Stilda) %*% t(b)

# Build PoT3 (4x3 matrix)
PoT3 <- matrix(0, nrow = 4, ncol = 3)
PoT3[1, 1] <- L3[1, 1]
PoT3[3, 1] <- L3[3, 1]

print("PoT3:")
print(PoT3)

###################
# 1) Step 3
###################
arg <- Po + PoT3

svd_res <- svd(arg)
a <- svd_res$u
S <- svd_res$d
b <- svd_res$v

print("Singular values S (Step 3):")
print(S)

# Soft-thresholding applied uniformly in step 3
Stilda <- S
Stilda[1] <- max(0, S[1] - lambda)
Stilda[2] <- max(0, S[2] - lambda)
Stilda[3] <- max(0, S[3] - lambda)
print("Stilda (Step 3):")
print(Stilda)

# Reconstruct L4: U * diag(Stilda) * V^T
L4 <- a %*% diag(Stilda) %*% t(b)

# Build PoT4 (4x3 matrix)
PoT4 <- matrix(0, nrow = 4, ncol = 3)
PoT4[1, 1] <- L4[1, 1]
PoT4[3, 1] <- L4[3, 1]

# Display history arrays to match Stata outputs
print("History of PoT matrices:")
print(list(PoT1 = PoT1, PoT2 = PoT2, PoT3 = PoT3, PoT4 = PoT4))

print("History of L matrices:")
print(list(L1 = L1, L2 = L2, L3 = L3, L4 = L4))

###################
# 1) Step 4
###################
arg <- Po + PoT4

#and keep on doing until convergence and for different values of lamda