package tests

import (
	"fmt"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestAll(t *testing.T) {
	t.Parallel()

	p, _ := filepath.Abs("../vars/test.tfvars")
	fmt.Println(p)

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		VarFiles: []string{
			p,
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.WorkspaceSelectOrNew(t, terraformOptions, "test")
	terraform.InitAndApply(t, terraformOptions)

	// dev-envインスタンスの存在確認
	assert.NotEmpty(t, terraform.Output(t, terraformOptions, "dev_instance_public_ip"))

	/* 動かねえええええええ(おこ)
	// goodnight lambdaの動作テスト
	functionName := terraform.Output(t, terraformOptions, "lambda_goodnight_function_name")
	aws.InvokeFunction(t, awsRegion, functionName, TestPayload{event: "autotest"})

	filters := map[string][]string{
		"tag:Author":          {"yamaguti-dxa"},
		"instance-state-name": {"running", "shutting-down"},
		"tag:Stage":           {"test"},
	}
	instancesAsleep := aws.GetEc2InstanceIdsByFilters(t, awsRegion, filters)

	// Goodnight Lambda実行したら起動しているインスタンスが存在しないこと
	assert.Equal(t, 0, len(instancesAsleep))
	*/
}

type TestPayload struct {
	event string
}
