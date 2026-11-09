# GCP Associate Cloud Engineer — Challenge Labs

Scripts en `bash` + `gcloud` para resolver los *challenge labs* de
[Google Cloud Skills Boost](https://www.cloudskillsboost.google/) del camino a la
certificación **Google Cloud Associate Cloud Engineer (ACE)**.

Cada challenge vive en su propia carpeta, es autocontenido y se puede
ejecutar completo o tarea por tarea.

## Challenges

| Carpeta | Tema | Qué crea |
|---|---|---|
| [`lb/`](lb/README.md) | Load balancing | VMs web, Network LB (regional, TCP) y HTTP LB global clásico con MIG |

> Se irán agregando más carpetas (una por challenge) a medida que se resuelvan.

## Requisitos

- Cuenta/lab activo en Google Cloud Skills Boost (credenciales temporales).
- `gcloud` autenticado (Cloud Shell sirve).
- `bash`, `curl`.

## Uso general

Los valores los asigna el panel del lab. Se exportan antes de correr:

```bash
export PROJECT_ID=<proyecto del lab>
export ZONE=<zona del lab>
export REGION=<región del lab>   # opcional, se deriva de ZONE
```

Luego, dentro de la carpeta del challenge:

```bash
bash run-all.sh   # todo en orden
bash verify.sh    # comprobar el resultado
bash cleanup.sh   # borrar recursos al terminar
```

## Estructura de un challenge

```
<challenge>/
├── README.md      # tareas, recursos creados, notas de diseño
├── env.sh         # variables compartidas (PROJECT_ID, REGION, ZONE)
├── run-all.sh     # ejecuta todas las tareas en orden
├── create-*.sh    # un script por tarea / grupo de recursos
├── verify.sh      # comprobaciones con curl / gcloud describe
└── cleanup.sh     # elimina lo creado, en orden inverso de dependencias
```

## Otros directorios

- `.archify/`: diagrama de arquitectura (HTML) del challenge `lb/`.
- `.claude-flow/`: datos de herramientas locales; no forman parte de los labs.

## Aviso

Los scripts están pensados para proyectos efímeros de laboratorio. Revisá
cada uno antes de ejecutarlo; `cleanup.sh` borra recursos por nombre fijo.
Algunos nombres de recursos no los fija el lab y pueden requerir ajuste si el
verificador espera otros (ver "Known limits" en cada README).
