library(tidyverse)
X2021_05_31_decoster_comparison <- haven::read_dta("Pro/BLASCOLIEPP/Code/21-03 Datasets V7 (JPubEc Resubmit)/DTA/2021_05_31_decoster_comparison.dta")
tauxdep <- read.csv2("./Pro/BLASCOLIEPP/Notes/2021-03 Resubmit JPubEc/desep.csv", sep=",")
prop_figari <- read.csv2("./Pro/BLASCOLIEPP/Notes/2021-03 Resubmit JPubEc/prop_figari.csv")

X2021_05_31_decoster_comparison %>% 
  mutate(
    itrc_carey_decoster = (oecd_5110+oecd_5121)/(oecd_P3-oecd_P31CP042),
    taux_effectif_carey = itrc_carey_decoster/(1+itrc_carey_decoster)*100,
    itrc_euro_decoster = (oecd_5110+oecd_5121)/(oecd_private_expenditure-oecd_P31CP042),
    taux_effectif_euro = itrc_euro_decoster/(1+itrc_euro_decoster)*100
  ) %>% 
  filter(cname != "Hungary" & cname != "Ireland") %>% 
  # pivot_longer(c(fig_ajuste2, fig_ajuste1, taux_figari)) %>% 
  pivot_longer(c(fig_ajuste2, taux_effectif_carey, taux_effectif_euro, taux_effectif)) %>% 
  mutate(name = fct_shift(factor(name), -1),
         name = fct_recode(name,
    # `Taux Figari` = "taux_figari",
    # `Taux Figari (ajusté des excise)` = "fig_ajuste1",
    `Taux Figari (ajusté des excise \net de la fraude)` = "fig_ajuste2",
    `Taux effectif ours` = "taux_effectif"
         )
    ) %>% 
  ggplot(aes(x=decile)) +
  geom_line(aes(y=value, col=name)) +
  # geom_line(aes(y=taux_effectif_carey), color="grey10") +
  geom_ribbon(aes(
    # ymin=taux_effectif_carey-1*abs(decile-5.5)/4.5, 
    # ymax=taux_effectif_carey+1*abs(decile-5.5)/4.5 
    # ), alpha=0.1) +
    ymin=value-1*abs(decile-5.5)/4.5, 
    ymax=value+1*abs(decile-5.5)/4.5 
    ), alpha=0.1, data=~filter(.x, name=="Taux effectif ours")) +
  geom_ribbon(aes(
    # ymin=taux_effectif_carey-1*abs(decile-5.5)/4.5, 
    # ymax=taux_effectif_carey+1*abs(decile-5.5)/4.5 
    # ), alpha=0.1) +
    ymin=value-1*abs(decile-5.5)/4.5, 
    ymax=value+1*abs(decile-5.5)/4.5 
  ), alpha=0.1, data=~filter(.x, name=="taux_effectif_carey")) +
  geom_ribbon(aes(
    # ymin=taux_effectif_carey-1*abs(decile-5.5)/4.5, 
    # ymax=taux_effectif_carey+1*abs(decile-5.5)/4.5 
    # ), alpha=0.1) +
    ymin=value-1*abs(decile-5.5)/4.5, 
    ymax=value+1*abs(decile-5.5)/4.5 
  ), alpha=0.1, data=~filter(.x, name=="taux_effectif_euro")) +
  facet_wrap(~cname) + ylim(c(0,17.5))

X2021_05_31_decoster_comparison %>% 
  left_join(prop_figari, by=c("cn", "decile" = "decile")) %>% 
  filter(cname != "Hungary" & cname != "Ireland") %>% 
  mutate(
    effort = prop*taux_effectif,
    effort_figari = prop*fig_ajuste2,
    effort_robustmin = prop*(taux_effectif-1*abs(decile-5.5)/4.5),
    effort_robustmax = prop*(taux_effectif+1*abs(decile-5.5)/4.5),
    ) %>% 
  pivot_longer(c(effort, effort_figari)) %>% 
  ggplot(aes(x=decile)) +
  geom_line(aes(y=value, col=name)) +
  geom_ribbon(aes(
    ymin=effort_robustmin, 
    ymax=effort_robustmax
  ), alpha=0.1) +
  facet_wrap(~cname) + ylim(0, 38)
 