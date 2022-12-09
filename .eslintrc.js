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
  rules: {
    'comma-dangle': 'off',
    '@typescript-eslint/comma-dangle': [
      'error',
      'only-multiline',
      {
        arrays: 'always',
        objects: 'always',
        imports: 'always',
        exports: 'always',
        functions: 'never',
      },
    ],
    'space-before-function-paren': 'off',
    '@typescript-eslint/space-before-function-paren': [
      'error',
      { anonymous: 'always', named: 'never', asyncArrow: 'always' },
    ],
    '@typescript-eslint/restrict-template-expressions': 'off',
  },
}
