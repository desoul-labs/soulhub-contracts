module.exports = {
  env: {
    browser: true,
    commonjs: true,
    es2021: true
  },
  plugins: [
    '@typescript-eslint',
    'import'
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    'ecmaVersion': 2018,
    'sourceType': 'module',
    'project': './tsconfig.json'
  },
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/eslint-recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:import/typescript'
  ],
  settings: {
    'import/parsers': {
      '@typescript-eslint/parser': [
        '.ts',
        '.tsx'
      ]
    },
    'import/resolver': {
      'node': {},
      'typescript': {
        'project': './tsconfig.json',
        'alwaysTryTypes': true
      }
    }
  },
  ignorePatterns: [
    '*.js',
    '!.projenrc.js',
    '*.d.ts',
    'node_modules/',
    '*.generated.ts',
    'coverage'
  ],
  rules: {
    'indent': [
      'off'
    ],
    '@typescript-eslint/indent': [
      'error',
      2
    ],
    'quotes': [
      'error',
      'single',
      {
        'avoidEscape': true
      }
    ],
    'comma-dangle': [
      'error',
      'always-multiline'
    ],
    'comma-spacing': [
      'error',
      {
        'before': false,
        'after': true
      }
    ],
    'no-multi-spaces': [
      'error',
      {
        'ignoreEOLComments': false
      }
    ],
    'array-bracket-spacing': [
      'error',
      'never'
    ],
    'array-bracket-newline': [
      'error',
      'consistent'
    ],
    'object-curly-spacing': [
      'error',
      'always'
    ],
    'object-curly-newline': [
      'error',
      {
        'multiline': true,
        'consistent': true
      }
    ],
    'object-property-newline': [
      'error',
      {
        'allowAllPropertiesOnSameLine': true
      }
    ],
    'keyword-spacing': [
      'error'
    ],
    'brace-style': [
      'error',
      '1tbs',
      {
        'allowSingleLine': true
      }
    ],
    'space-before-blocks': [
      'error'
    ],
    'curly': [
      'error',
      'multi-line',
      'consistent'
    ],
    '@typescript-eslint/member-delimiter-style': [
      'error'
    ],
    'semi': [
      'error',
      'always'
    ],
    'max-len': [
      'error',
      {
        'code': 150,
        'ignoreUrls': true,
        'ignoreStrings': true,
        'ignoreTemplateLiterals': true,
        'ignoreComments': true,
        'ignoreRegExpLiterals': true
      }
    ],
    'quote-props': [
      'error',
      'consistent-as-needed'
    ],
    '@typescript-eslint/no-require-imports': [
      'error'
    ],
    'import/no-extraneous-dependencies': [
      'error',
      {
        'devDependencies': [
          '**/test/**',
          '**/build-tools/**'
        ],
        'optionalDependencies': false,
        'peerDependencies': true
      }
    ],
    'import/no-unresolved': [
      'error'
    ],
    "import/resolver": {
      "node": {
        "extensions": [".js", ".jsx", ".ts", ".tsx"]
      }
    },
    'import/order': [
      'warn',
      {
        'groups': [
          'builtin',
          'external'
        ],
        'alphabetize': {
          'order': 'asc',
          'caseInsensitive': true
        }
      }
    ],
    'no-duplicate-imports': [
      'error'
    ],
    'no-shadow': [
      'off'
    ],
    '@typescript-eslint/no-shadow': [
      'error'
    ],
    'key-spacing': [
      'error'
    ],
    'no-multiple-empty-lines': [
      'error'
    ],
    '@typescript-eslint/no-floating-promises': [
      'error'
    ],
    'no-return-await': [
      'off'
    ],
    '@typescript-eslint/return-await': [
      'error'
    ],
    'no-trailing-spaces': [
      'error'
    ],
    'dot-notation': [
      'error'
    ],
    'no-bitwise': [
      'error'
    ],
    '@typescript-eslint/member-ordering': [
      'error',
      {
        'default': [
          'public-static-field',
          'public-static-method',
          'protected-static-field',
          'protected-static-method',
          'private-static-field',
          'private-static-method',
          'field',
          'constructor',
          'method'
        ]
      }
    ]
  }
}