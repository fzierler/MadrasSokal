#"12345.67(0.12)"
#"12345.67(1.2)"
#"12345.67(12.0)"

Δx1 = 0.12
Δx2 = 1.2
Δx3 = 12
nsig = 2

e1 = round(Δx1,sigdigits=nsig)
e2 = round(Δx2,sigdigits=nsig)
e3 = round(Δx3,sigdigits=nsig)

floor_log10_x1 = floor(Int,log10(Δx1))
floor_log10_x2 = floor(Int,log10(Δx2))
floor_log10_x3 = floor(Int,log10(Δx3))

dec_digits = floor_log10_x1 - (nsig - 1)
dec_digits = floor_log10_x2 - (nsig - 1)
dec_digits = floor_log10_x3 - (nsig - 1)