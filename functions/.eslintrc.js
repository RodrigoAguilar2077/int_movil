module.exports = {
  env: {
    es6: true,
    node: true, // Asegura que Node.js está habilitado como entorno
  },
  parserOptions: {
    ecmaVersion: 2018, // Permite la sintaxis moderna de JavaScript
  },
  extends: [
    "eslint:recommended", // Reglas recomendadas de ESLint
    "google", // Estilo de código Google
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],
    "no-undef": "off", // Deshabilita la regla no-undef para permitir "require" y "exports"
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true, // Habilita el entorno de Mocha para las pruebas
      },
      rules: {},
    },
  ],
  globals: {},
};
