# Skill: Ralph Loop

Autonomous iteration loop para completar tareas sin intervención.

## Comandos

### Iniciar Ralph Loop
```
/ralph-loop start
/ralph-loop
```

### Detener Ralph Loop
```
/ralph-loop stop
/cancel-ralph
```

### Ver estado
```
/ralph-loop status
```

## Instrucciones

Cuando el usuario invoque este skill:

### Para START:
1. Crear el archivo `/tmp/ralph-loop-enabled` para activar el loop
2. Informar al usuario que Ralph Loop está activo
3. Recordar que debe incluir `RALPH_COMPLETE` cuando la tarea esté terminada
4. Continuar trabajando en la tarea actual

```bash
# Activar Ralph Loop
touch /tmp/ralph-loop-enabled
echo '{"iteration": 0}' > /tmp/ralph-loop-state
```

### Para STOP:
1. Eliminar los archivos de estado
2. Confirmar que el loop fue detenido

```bash
# Desactivar Ralph Loop
rm -f /tmp/ralph-loop-enabled /tmp/ralph-loop-state
```

### Para STATUS:
1. Verificar si está activo
2. Mostrar iteración actual si está corriendo

```bash
if [[ -f /tmp/ralph-loop-enabled ]]; then
  echo "🍩 Ralph Loop: ACTIVO"
  cat /tmp/ralph-loop-state 2>/dev/null || echo "Iteración: 0"
else
  echo "🍩 Ralph Loop: INACTIVO"
fi
```

## Configuración

Variables de entorno opcionales:
- `RALPH_SAFE_WORD`: Palabra para indicar completado (default: `RALPH_COMPLETE`)
- `RALPH_MAX_ITERATIONS`: Máximo de iteraciones (default: 50)

## Ejemplo de Uso

```
Usuario: /ralph-loop start
         Hacé que todos los tests pasen

Claude: 🍩 Ralph Loop activado. Voy a trabajar hasta que todos los tests pasen.
        [trabaja en los tests...]

        ✅ Todos los tests pasan ahora.
        RALPH_COMPLETE
```

## Mejores Casos de Uso

- ✅ Correr tests hasta que pasen
- ✅ Fixear errores de TypeScript/lint
- ✅ Build que tiene que compilar
- ✅ Refactoring con verificación automática
- ❌ Tareas sin criterio claro de éxito
- ❌ Tareas que requieren input del usuario
