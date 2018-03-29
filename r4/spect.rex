/* the spectral test in REXX */

/*
   purpose: to evaluate the "goodness" of an LCG random number generator
   given its multiplier (a) and effective modulus (m)

   note: the effective modulus (m) may be less than the actual modulus
   in some cases, for example RANDU has modulus 2**31 but effective
   modulus (m) = 2**29 because the increment (c) = 0 (see reference)

   reference: Knuth, vol 2, 2nd ed, pp 98-101

   output: this program calculates the values of s**2(t) for t=2..6
   these values are then passed to an awk program
   which converts them to v(t) and mu(t)

   debug & diagnostics: outputs u matrix and z vector so you can
   bench check it against the example in Knuth, and so that you
   can visually verify that the shortest u vector satisfies the
   congruence equation (see reference)

   input data: a and m as optional command line arguments
   if a and m are not supplied the default values are
   those for IBM's RANDU

   beware: check to make sure numeric digits is large enough
   it should be at least twice as large as (m)
   the calculations require *exact* integer arithmetic

   history: a straightforward but crude translation of Knuth's "Algorithm S"
   it replaces a program written in UCSD Pascal on the Apple II in 1986
   
   author: E P Chandler
   date: 3 May 2004
   e-mail: epc8@juno.com
   restrictions: none as long as you retain my name and e-mail as author
*/

numeric digits 20 /* is this large enough? */

parse arg a m

if a='' then a=2**16 + 3
if m='' then m=2**29 /* c = 0 so m=2**31 / 4 */

/*s1*/
h=a
hp=m
p=1
pp=0
r=a
s=1+a*a

/*s2*/
do until f=0
  q=hp%h
  u=hp-q*h
  v=pp-q*p
  f=u*u+v*v<s
  if f then do
    s=u*u+v*v
    hp=h
    h=u
    pp=p
    p=v
  end
end

/*s3*/
u=u-h
v=v-p
if u*u+v*v<s then do /* fixed */
  s=u*u+v*v
  hp=u
  pp=v
end

u.1.1=-h;  u.1.2=p
u.2.1=-hp; u.2.2=pp

v.1.1=pp;  v.1.2=hp
v.2.1=-p;  v.2.2=-h

if pp>0 then
  do i=1 to 2
    do j=1 to 2
      v.i.j=-v.i.j
    end
  end

mu=s

do t=3 to 6
/*s4*/

r=(a*r)//m

do k=1 to t-1
  u.t.k=0
  u.k.t=0
  v.t.k=0
end
u.t.1=-r
u.t.t=1
v.t.t=m

do i=1 to t-1
  q=format(v.i.1*r/m,,0) /** fixed **/
  v.i.t=v.i.1*r-q*m
  do j=1 to t
    u.t.j=u.t.j+q*u.i.j
  end
end

sp=0
do j=1 to t
  sp=sp+u.t.j*u.t.j
end
if sp < s then s=sp

k=t
j=1

do until j=k
/*s5*/
do i=1 to t
  if i<>j then do
    vij=0
    vjj=0
    do n=1 to t
      vij=vij+v.i.n*v.j.n
      vjj=vjj+v.j.n*v.j.n
    end
    if 2*abs(vij)>vjj then do
      q=format(vij/vjj,,0) /** fixed **/
      do n=1 to t
        v.i.n=v.i.n-q*v.j.n
        u.j.n=u.j.n+q*u.i.n
      end
      k=j
    end
  end
end

/*s6*/
if k=j then do
  sp=0
  do n=1 to t
    sp=sp+u.j.n*u.j.n
  end
  if sp < s then s=sp
end

/*s7*/
j=j+1
if j>t then j=1

end /* if j<>k -> s5 */

/** dump u **/
say 'u='
do xx=1 to t
  uu=''
  do yy=1 to t
  uu=uu u.xx.yy
  end
  say uu
end
/** dump u **/

/*s8*/
do j=1 to t
  vjj=0
  do n=1 to t
    vjj=vjj+v.j.n*v.j.n
  end
  x.j=0
  y.j=0
  z.j=trunc(vjj*s/(m*m)) /** ok **/
  z=0 /* floor(sqrt()) */
  do while (z+1)*(z+1)<(z.j+1)
    z=z+1
  end
  z.j=z
end

/** dump z **/
  zz=''
  do xx=1 to t
    zz=zz z.xx
  end
  say 'z=' zz
/** dump z **/

k=t

do until k=0
/*s9*/
if x.k<>z.k then do
  x.k=x.k+1
  do n=1 to t
    y.n=y.n+u.k.n
  end

/*s10*/
  do k=k+1 to t
    x.k=-z.k
    do n=1 to t
      y.n=y.n-2*z.k*u.k.n
    end
  end

  sp=0
  do n=1 to t
    sp=sp+y.n*y.n
  end
  if sp < s then do
    s=sp
    say 's has been reduced'
  end
  k=t+1
end

/*s11*/
k=k-1
end /* if k>=1 -> s9 */

mu=mu s

end /* loop on t -> s4 */

say a m mu

exit
