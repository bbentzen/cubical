{-

Basic properties about Σ-types

- Characterization of equality in Σ-types using transport ([pathSigma≡sigmaPath])
- HLevel of Σ-types ([isOfHLevelΣ])

-}
{-# OPTIONS --cubical --safe #-}
module Cubical.Data.Sigma.Properties where

open import Cubical.Data.Sigma.Base

open import Cubical.Core.Everything

open import Cubical.Foundations.Equiv
open import Cubical.Foundations.HLevels
open import Cubical.Foundations.CartesianKanOps

open import Cubical.Data.Nat.Base

private
  variable
    ℓ ℓ' : Level
    A : Set ℓ
    B : (a : A) → Set ℓ'

-- alternative version for path in Σ-types, as in the HoTT book

sigmaPathTransport : (a b : Σ A B) → Set _
sigmaPathTransport {B = B} a b =
  Σ (fst a ≡ fst b) (λ p → transport (λ i → B (p i)) (snd a) ≡ snd b)

_Σ≡_ : (a b : Σ A B) → Set _
a Σ≡ b = sigmaPathTransport a b

-- now we prove that the alternative path space a Σ≡ b is equal to the usual path space a ≡ b

-- forward direction

private
  pathSigma-π1 : {a b : Σ A B} → a ≡ b → fst a ≡ fst b
  pathSigma-π1 p i = fst (p i)

  filler-π2 : {a b : Σ A B} → (p : a ≡ b) → I → (i : I) → B (fst (p i))
  filler-π2 {B = B} {a = a} p i =
    fill (λ i → B (fst (p i)))
         (λ t → λ { (i = i0) → coe0→i (λ j → B (fst (p j))) t (snd a)
                  ; (i = i1) → snd (p t) })
         (inS (snd a))

  pathSigma-π2 : {a b : Σ A B} → (p : a ≡ b) →
    subst B (pathSigma-π1 p) (snd a) ≡ snd b
  pathSigma-π2 p i = filler-π2 p i i1

pathSigma→sigmaPath : (a b : Σ A B) → a ≡ b → a Σ≡ b
pathSigma→sigmaPath _ _ p = (pathSigma-π1 p , pathSigma-π2 p)

-- backward direction

private
  filler-comp : (a b : Σ A B) → a Σ≡ b → I → I → Σ A B
  filler-comp {B = B} a b (p , q) i =
    hfill (λ t → λ { (i = i0) → a
                   ; (i = i1) → (p i1 , q t) })
          (inS (p i , coe0→i (λ j → B (p j)) i (snd a)))

sigmaPath→pathSigma : (a b : Σ A B) → a Σ≡ b → (a ≡ b)
sigmaPath→pathSigma a b x i = filler-comp a b x i i1

-- first homotopy

private
  homotopy-π1 : (a b : Σ A B) →
    ∀ (x : a Σ≡ b) → pathSigma-π1 (sigmaPath→pathSigma a b x) ≡ fst x
  homotopy-π1 a b x i j = fst (filler-comp a b x j (~ i))

  homotopy-π2 : (a b : Σ A B) → (p : a Σ≡ b) → (i : I) →
             (transport (λ j → B (fst (filler-comp a b p j i))) (snd a) ≡ snd b)
  homotopy-π2 {B = B} a b p i j =
    comp (λ t → B (fst (filler-comp a b p t (i ∨ j))))
         (λ t → λ { (j = i0) → coe0→i (λ t → B (fst (filler-comp a b p t i)))
                                      t (snd a)
                  ; (j = i1) → snd (sigmaPath→pathSigma a b p t)
                  ; (i = i0) → snd (filler-comp a b p t j)
                  ; (i = i1) → filler-π2 (sigmaPath→pathSigma a b p) j t })
         (inS (snd a))

pathSigma→sigmaPath→pathSigma : {a b : Σ A B} →
  ∀ (x : a Σ≡ b) → pathSigma→sigmaPath _ _ (sigmaPath→pathSigma a b x) ≡ x
pathSigma→sigmaPath→pathSigma {a = a} p i =
  (homotopy-π1 a _ p i , homotopy-π2 a _ p (~ i))

-- second homotopy

sigmaPath→pathSigma→sigmaPath : {a b : Σ A B} →
  ∀ (x : a ≡ b) → sigmaPath→pathSigma a b (pathSigma→sigmaPath _ _ x) ≡ x
sigmaPath→pathSigma→sigmaPath {B = B} {a = a} {b = b} p i j =
  hcomp (λ t → λ { (i = i1) → (fst (p j) , filler-π2 p t j)
                 ; (i = i0) → filler-comp a b (pathSigma→sigmaPath _ _ p) j t
                 ; (j = i0) → (fst a , snd a)
                 ; (j = i1) → (fst b , filler-π2 p t i1) })
        (fst (p j) , coe0→i (λ k → B (fst (p k))) j (snd a))

pathSigma≡sigmaPath : (a b : Σ A B) → (a ≡ b) ≡ (a Σ≡ b)
pathSigma≡sigmaPath a b =
  isoToPath (iso (pathSigma→sigmaPath a b)
                 (sigmaPath→pathSigma a b)
                 (pathSigma→sigmaPath→pathSigma {a = a})
                 sigmaPath→pathSigma→sigmaPath)


-- H-level for Σ-types

isOfHLevelΣ : ∀ n → isOfHLevel n A → ((x : A) → isOfHLevel n (B x)) → isOfHLevel n (Σ A B)
isOfHLevelΣ zero h1 h2 =
  let center = (fst h1 , fst (h2 (fst h1))) in
  let p : ∀ x → center ≡ x
      p = λ x → sym (sigmaPath→pathSigma _ _ (sym (snd h1 (fst x)) , sym (snd (h2 (fst h1)) _)))
  in (center , p)
isOfHLevelΣ 1 h1 h2 x y = sigmaPath→pathSigma x y ((h1 _ _) , (h2 _ _ _))
isOfHLevelΣ {B = B} (suc (suc n)) h1 h2 x y =
  let h3 : isOfHLevel (suc n) (x Σ≡ y)
      h3 = isOfHLevelΣ (suc n) (h1 (fst x) (fst y)) λ p → h2 (p i1)
                       (subst B p (snd x)) (snd y)
  in transport (λ i → isOfHLevel (suc n) (pathSigma≡sigmaPath x y (~ i))) h3
