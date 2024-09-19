import type { ValidationAcceptor, ValidationChecks } from 'langium';
import type { UvlparserAstType, Person } from './generated/ast.js';
import type { UvlparserServices } from './uvlparser-module.js';

/**
 * Register custom validation checks.
 */
export function registerValidationChecks(services: UvlparserServices) {
    const registry = services.validation.ValidationRegistry;
    const validator = services.validation.UvlparserValidator;
    const checks: ValidationChecks<UvlparserAstType> = {
        Person: validator.checkPersonStartsWithCapital
    };
    registry.register(checks, validator);
}

/**
 * Implementation of custom validations.
 */
export class UvlparserValidator {

    checkPersonStartsWithCapital(person: Person, accept: ValidationAcceptor): void {
        if (person.name) {
            const firstChar = person.name.substring(0, 1);
            if (firstChar.toUpperCase() !== firstChar) {
                accept('warning', 'Person name should start with a capital.', { node: person, property: 'name' });
            }
        }
    }

}
