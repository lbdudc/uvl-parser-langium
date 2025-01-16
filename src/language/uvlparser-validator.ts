import type { ValidationAcceptor, ValidationChecks } from 'langium';
import type { UvlparserAstType, FeatureModel } from './generated/ast.js';
import type { UvlparserServices } from './uvlparser-module.js';

/**
 * Register custom validation checks.
 */
export function registerValidationChecks(services: UvlparserServices) {
    const registry = services.validation.ValidationRegistry;
    const validator = services.validation.UvlparserValidator;
    const checks: ValidationChecks<UvlparserAstType> = {
        FeatureModel: validator.checkFeatureModelValidity
    };
    registry.register(checks, validator);
}

/**
 * Implementation of custom validations.
 */
export class UvlparserValidator {

    checkFeatureModelValidity(featureModel: FeatureModel, accept: ValidationAcceptor): void {
    }

}
