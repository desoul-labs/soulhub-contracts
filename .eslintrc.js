module.exports = {
  env: {
    browser: true,
    es2021: true,
  },
  extends: 'standard-with-typescript',
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint'],
  overrides: [],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
    project: './tsconfig.json',
  },
  rules: {},
}
