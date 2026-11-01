# soho-guard-site-lab

Repozytorium **instalacji** `lab` (ADR-002): jedna instalacja SOHO, w niej wiele routerów.
W labie publiczne; w realnym wdrożeniu prywatne.

```
site.yml                 instalacja: id, pin wersji polityki, heartbeat, lista routerów
routers/<router_id>/     dane jednego routera
  inventory.yml            onboarding fazy 0' + przegląd człowieka (SSOT routera)
  baseline-state.yml       wzorzec driftu (onboarding na utwardzonym routerze)
  onboarding-findings.yml  wynik weryfikacji wobec polityki w chwili adopcji
  export.rsc               /export hide-sensitive — bez sekretów
  dynamic-baseline.yml     ręczny baseline behawioralny (ADR-006)
  baseline.rsc.j2          szablon baseline (wartości tajne tylko jako {{ vault_* }})
  host_vars.yml            dane instalacji dla szablonu
state/<router_id>.json   stan agenta (ADR-005)
reports/<router_id>/     raporty agenta (ADR-005)
```

Onboarding (z klonu soho-guard, repo obok):

    python3 ../soho-guard/tools/mikrotik_onboard.py --host 10.100.1.1 --user monitor --password "$PW" \
      --site-id lab --router-id r1 --out-dir routers --tls --ca-file /etc/soho-guard/ca.crt \
      --policy-dir ../soho-guard/policy --skip-rsc

Wyrenderowany baseline (`*.rendered.rsc`) powstaje wyłącznie w `build/` stacji operatora i **nie jest commitowany**.
