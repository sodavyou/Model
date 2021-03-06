#########################
# Outfall002 coordenates
########################

library(tidyverse)

data=read.csv("Data/ChannelMatlab.csv", sep=";", dec = ",", na.strings = "NaN")  # loading Outfall 002 Data

data$X <- data$X*2.54/100 # Convert to meters 
data$Y <- data$Y*2.54/100
data$Z <- data$Z/100

slopes=read.csv("Data/slopes.csv")  #integrate slopes
slopes.expanded <- slopes[rep(row.names(slopes), slopes$Rep), 1:2] %>%
  select(Slope)
data <- bind_cols(data, slopes.expanded)

A <- 0
P <- 0
Y <- 0

for (i in 1:max(data$Section)){
  
  # extract profile of interest
  profile <- data %>%
    filter(Section == i, !Position == "Mid") %>%
    select(Position, Y, Z, n, Slope)
  
  plot(profile$Y, -profile$Z)
  # Sys.sleep(2)
  
  n = mean(profile$n) # Calculate the mean of n 
  
  # Extract vertices
  
  a <- filter(profile, Position == "Lout") %>%
    select(Y,Z)
  
  b <- filter(profile, Position == "Lin") %>%
    select(Y,Z)
  
  c <- filter(profile, Position == "Rin") %>%
    select(Y,Z)
  
  d <- filter(profile, Position == "Rout") %>%
    select(Y,Z)
  
#  e <- filter(profile, Position == "Lout") %>%
#    select(Y,Z)
  
  z1 <- 1/abs((b$Z-a$Z)/(b$Y-a$Y))
  z2 <- 1/abs((d$Z-c$Z)/(d$Y-c$Y))
  # Calculate area
  Base <- d$Y-a$Y
  base <- c$Y-b$Y
  h1 <- b$Z
  h2 <- c$Z
  abc <- base*h1/2
  acd <- Base*h2/2
  A[i] = abc + acd
  
  # calcular perìmetro
  
  l1 <- sqrt((a$Y-b$Y)^2+(a$Z-b$Z)^2)
  l2 <- sqrt((b$Y-c$Y)^2+(b$Z-c$Z)^2)
  l3 <- sqrt((c$Y-d$Y)^2+(c$Z-d$Z)^2)
  l4 <- sqrt((d$Y-a$Y)^2+(d$Z-a$Z)^2)
  
  P[i] <- l1+l2+l3+l4
  
  # calcular pendiente
  s1 <- filter(profile, Position == "Rout") %>%
    select(Slope)
  s <- s1$Slope
  
  # Iterate over values of y to make them match Qobs
  b <- base
  
  y = 0;
  
  Qobs <- 460 * 3.785 / 1000 
  Q <- (1/n)*(((y/2)*(b+(b+y*(z1+z2))))^(5/3))/((b+y*(sqrt(1+z1^2)+sqrt(1+z2^2)))^(2/3))*(s^(1/2))
  
  D <- abs(Q-Qobs)
  
  while (D>0.01){
    y <- y+0.0001
    Q <- (1/n)*(((y/2)*(b+(b+y*(z1+z2))))^(5/3))/((b+y*(sqrt(1+z1^2)+sqrt(1+z2^2)))^(2/3))*(s^(1/2))
  D <- abs(Q-Qobs)
  }
  
  Y[i] <- y
  
}

R<- A/P
V <- (R^(2/3)*sqrt(s))/(n)
Q <- A*V

Section <- seq(1:max(data$Section))

flow <- data.frame(Section, A, P, R, V, Q, Y)
data <- left_join(data, flow, by = "Section")

Waterdepth<-data.frame(Section,Y)

write.csv(Waterdepth, file = "Data/WD.csv", row.names = F)


write.csv(data, file = "Data/Channel.csv", row.names = F)
write.csv(flow, file = "Data/Flow.csv", row.names = F)

# for(i in 1:10){
#   JC[i] <- 2*i+4
#   print(i)
# }



















